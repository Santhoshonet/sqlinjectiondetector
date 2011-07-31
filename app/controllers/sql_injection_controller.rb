require "nokogiri"
require "open-uri"
require 'net/http'
require 'net/https'
require "uri"
class SqlInjectionController < ApplicationController

  def index
    unless params[:siteid].nil?
      site = Site.find_by_id(params[:siteid])
      unless site.nil?
        # getting root url
        unless site.is_it_root
          site.url = get_root_site_url(site.url)
          site.is_it_root = true
          site.save
        end
        iterationno = 1
        unless params[:iterationid].nil?
          iterationno = params[:iterationid].to_i
        end
        #if site.status == false
        get_base_content(site)
        #end
        sql_injection_query = SqlInjectionQuery.find_by_id(iterationno)
        unless sql_injection_query.nil?
          doc = Nokogiri::HTML(open(site.url))
          doc.xpath('//form').each do |form|
              response = get_http_response(form,sql_injection_query.query,site)
              save_site_content(response,site)
          end
        end
      end
    end
    data = {}
    data[:status] = "success"
    render :json => data
  end

  def check
    
  end

  private
  def get_base_content(site)
    response = get_site_content(site.url)
    if response.code.to_i < 400
      doc = Nokogiri::HTML(response.body)
      doc.xpath('//form').each do |form|
        action = form.attr('action')
        parameters = {}
        doc.search('input[type="text"],input[type="hidden"]').each do |input|
          unless input.attr('name').nil?
            parameters[input.attr('name')] = random_string(20)
          end
        end
        unless action.nil?
          url = site.url + "/" + action
          url = url.gsub("//","/")
          uri = URI.parse(url)
          if uri.scheme.to_s.downcase == "https"
            url = url.gsub("https:/", "https://")
          else
            url = url.gsub("http:/", "http://")
          end
          uri = URI.parse(url)
          http = Net::HTTP.new(uri.host,uri.port)
          # if is secured site
          if uri.scheme.to_s.downcase == "https"
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          request = Net::HTTP::Post.new(uri.request_uri)
          # posting form values
          request.set_form_data(parameters)
          response = http.request(request)
          if response.code.to_i != 200
            # try with query string and get the result
            # if it the site is http authenticated
            if response.code.to_i == 401
              site.comment = "HTTP access Authentication required for this site"
              http = Net::HTTP.new(uri.host,uri.port)
              # if is secured site
              if uri.scheme.to_s.downcase == "https"
                http.use_ssl = true
                http.verify_mode = OpenSSL::SSL::VERIFY_NONE
              end
              request = Net::HTTP::Get.new(uri.request_uri)
              request_basic_auth(random_string(20),random_string(20))
              response = http.request (request)
              save_web_response(response,site)
            else
              # here we need to try with query string
              # adding query string to Uri
              uri = URI.parse(url + "?" + parameters.to_query)
              http = Net::HTTP.new(uri.host,uri.port)
               # if is secured site
              if uri.scheme.to_s.downcase == "https"
                http.use_ssl = true
                http.verify_mode = OpenSSL::SSL::VERIFY_NONE
              end
              request = Net::HTTP::Get.new(uri.request_uri)
              response = http.request(request)
              save_web_response(response,site)
            end
          else
            save_web_response(response,site)
          end
        end
      end
    else
      save_web_response(response,site)
    end
  end

  def random_string(len)
    #generat a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    newpass
  end

  def save_web_response(response,site)
    save_site_content(response,site)
    if response.code.to_i == 200
      site.base_html = response.body
      site.status = true
      site.is_http_authenticated = false
      site.save
    elsif response.code.to_i > 200 && response.code.to_i < 400
      # saving the redirect page to db
      site.response_code = response.code.to_i
      site.base_html = response.body
      site.comment = ""
      site.status = true
      site.is_http_authenticated = false
      site.save
    else
      site.response_code = response.code.to_i
      site.base_html = response.body
      site.comment = "Error page returned."
      site.status = false
      site.is_http_authenticated = false
      site.save
    end
  end

  def save_site_content(response, site)
    sitecontent = SiteContent.new
      sitecontent.site_id = site.id
      sitecontent.data = html_escape(response.body)
      sitecontent.response_code = response.code.to_i
      unless sitecontent.save
        puts sitecontent.errors.full_messages
      end
  end

  def get_site_content(url)
    puts url
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host,uri.port)
    # if is secured site
    if uri.scheme.to_s.downcase == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    while response.code.to_i >= 300 && response.code.to_i < 303
      doc = Nokogiri::HTML(response.body)
      doc.xpath('//a').each do |link|
        begin
            uri = URI.parse(link.attr('href'))
            http = Net::HTTP.new(uri.host,uri.port)
            # if is secured site
            if uri.scheme.to_s.downcase == "https"
              http.use_ssl = true
              http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            end
            request = Net::HTTP::Get.new(uri.request_uri)
            response = http.request(request)
        rescue
        end
      end
    end
    response
  end

  def get_root_site_url(url)
    root_url = url
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host,uri.port)
    # if is secured site
    if uri.scheme.to_s.downcase == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    while response.code.to_i >= 300 && response.code.to_i < 303
      doc = Nokogiri::HTML(response.body)
      doc.xpath('//a').each do |link|
        begin
            uri = URI.parse(link.attr('href'))
            root_url = link.attr('href')
            http = Net::HTTP.new(uri.host,uri.port)
            # if is secured site
            if uri.scheme.to_s.downcase == "https"
              http.use_ssl = true
              http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            end
            request = Net::HTTP::Get.new(uri.request_uri)
            response = http.request(request)
        rescue
        end
      end
    end
    root_url
  end

  def save_site_content(response,site)
    site_content = SiteContent.new
    site_content.response_code = response.code.to_i
    site_content.data = response.body
    site_content.site_id = site.id
    site_content.save
  end

  def get_http_response(form,qry,site)
    action = form.attr('action')
    parameters = {}
    form.search('input[type="text"],input[type="hidden"]').each do |input|
      unless input.attr('name').nil?
        parameters[input.attr('name')] = qry
      end
    end

    if (action.to_s.downcase.index("http") == 0)
      url = action.to_s
    else
      url = site.url
    end

    url = url.gsub("//","/")
    uri = URI.parse(url)

    if uri.scheme.to_s.downcase == "https"
      url = url.gsub("https:/", "https://")
    else
      url = url.gsub("http:/", "http://")
    end

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host,uri.port)
    # if is secured site
    if uri.scheme.to_s.downcase == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    
    request = Net::HTTP::Post.new(uri.request_uri)
    # posting form values
    request.set_form_data(parameters)
    response = http.request(request)
    if response.code.to_i != 200
      # try with query string and get the result
      # if it the site is http authenticated
      if response.code.to_i == 401
        http = Net::HTTP.new(uri.host,uri.port)
        # if is secured site
        if uri.scheme.to_s.downcase == "https"
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        request = Net::HTTP::Get.new(uri.request_uri)
        request_basic_auth(qry,qry)
        response = http.request (request)
      else
        # here we need to try with query string
        # adding query string to Uri
        uri = URI.parse(url + "?" + parameters.to_query)
        http = Net::HTTP.new(uri.host,uri.port)
        # if is secured site
        if uri.scheme.to_s.downcase == "https"
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
      end
    end
    response
  end
  
end
