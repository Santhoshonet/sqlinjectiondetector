# this is class is create for delayed_job , right now not using this
class SqlinjectionLib < Struct.new(:site)
  def perform
    Sql_injection_module.perform(site)
  end
end
module Sql_injection_module
  require "nokogiri"
  require "open-uri"
  require "net/http"
  require "net/https"
  def perform(site)
    SqlInjectionQuery.all.each do |sql_injection_query|
      #doc = Nokogiri::HTML(open(site.url))
      #doc.xpath('//form').each do |form|
      # response = get_http_response(form,sql_injection_query.query,site)
      # save_site_content(response,site,sql_injection_query.id)
      #end
      get_http_response(sql_injection_query.query,site,sql_injection_query.id)
    end
  end

    ## -------- SQL Injection methods ---------------

    def get_base_content(site)
      response = get_site_content(site.url)
      cookie = response['Set-Cookie']
      #saving cookie
      site.cookie = cookie
      site.save
      if response.code.to_i < 400
        doc = Nokogiri::HTML(response.body)
        doc.xpath('//form').each do |form|
          action = form.attr('action')
          parameters = set_parameters(doc,random_string(20))
          unless action.nil?
            uri = get_post_back_url(site.url,action)
            response = get_response_with_parameters(uri,parameters,site.cookie)
            if response.code.to_i != 200
              # try with query string and get the result
              # if it the site is http authenticated
              if response.code.to_i == 401
                site.comment = "HTTP access Authentication required for this site"
                response = get_response_with_windows_auth(uri,cookie,random_string(20),random_string(20))
                save_initial_response(response,site)
              else
                # here we need to try with query string,  adding query string to Uri
                response = get_response_with_cookie(uri.scheme + "://" + uri.host  +  uri.request_uri +  "?" + parameters.to_query.to_s,cookie)
                save_initial_response(response,site)
              end
            else
              save_initial_response(response,site)
            end
          end
        end
      else
        save_initial_response(response,site)
      end
    end

    def get_root_site_url(url)
      root_url = url
      response = get_response(url)
      # index to exit if it got too long redirects
      index = 1
      begin
        while response.code.to_i >= 300 && response.code.to_i < 303 && index < 10
          doc = Nokogiri::HTML(response.body)
          is_link_found = false
          doc.xpath('//a').each do |link|
            root_url = link.attr('href')
            response = get_response(root_url)
            is_link_found = true
          end
          if is_link_found == false
            root_url = response['Location'].to_s
            index = index + 1
          end
        end
      rescue
      end
      root_url
    end

    def get_post_back_url(url_original,action)
      url = ''
      if action.to_s.downcase.index("http") == 0 || action.to_s.downcase.index("https") == 0
        url = action.to_s
      else
        if action.to_s.downcase.index("/") == 0
          uri = URI.parse(url_original)
          url = uri.scheme + "://" + uri.host + action #uri.request_uri
        else
          unless action.nil?
            url = url_original + "/" + action
          else
            url = url_original
          end
        end
      end
      url = url.gsub("//","/")
      uri = URI.parse(url)
      if uri.scheme.to_s.downcase == "https"
        url = url.gsub("https:/", "https://")
      else
        url = url.gsub("http:/", "http://")
      end
      uri = URI.parse(url)
      uri
    end

    def get_http_response(qry,site,sql_injection_query_id)
      response = get_site_content(site.url)
      cookie = response['Set-Cookie']
      if response.code.to_i < 400
        doc = Nokogiri::HTML(response.body)
        doc.xpath('//form').each do |form|
          action = form.attr('action')
          parameters = set_parameters(form,qry)
          uri = get_post_back_url(site.url,action)
          unless action.nil?
            response = get_response_with_parameters(uri,parameters,cookie)
            if response.code.to_i != 200
              # try with query string and get the result if it the site is http authenticated
              if response.code.to_i == 401
                response = get_response_with_windows_auth(uri,site.cookie,qry,qry)
              else
                # here we need to try with query string, adding query string to Uri
                response = get_response(site.url + "?" + parameters.to_query)
              end
            end
            save_site_content(response,site,sql_injection_query_id)
          else
            # here we need to try with query string, adding query string to Uri
            response = get_response(site.url + "?" + parameters.to_query)
            save_site_content(response,site,sql_injection_query_id)
          end
        end
      end
    end

    def get_site_content(url)
      response = get_response(url)
    # index to exit if it got too long redirects
      index = 1
      while response.code.to_i >= 300 && response.code.to_i < 303 && index < 11
        doc = Nokogiri::HTML(response.body)
        is_link_found = false
        doc.xpath('//a').each do |link|
          begin
             response = get_response(link.attr('href'))
          rescue
          end
          is_link_found = true
        end
        if is_link_found == false
            index = index +1
            response = get_response(response['Location'].to_s)
        end
      end
      response
    end

    def set_parameters(doc,qry)
      parameters = {}
      doc.search('input[type="hidden"]').each do |input|
        unless input.attr('name').nil?
          parameters[input.attr('name')] = input.attr('value')
        end
      end
      unless qry.nil?
        doc.search('input[type="text"],input[type="password"]').each do |input|
          unless input.attr('name').nil?
            parameters[input.attr('name')] = qry
          end
        end
      end
      parameters
    end

    # --------  ---------------


    ## -------- database related methods ---------------

    def save_initial_response(response,site)
      save_site_content(response,site,0)
      if response.code.to_i == 200
        site.base_html = modify_file_urls(response.body,site.url)
        site.status = true
        site.is_http_authenticated = false
        site.save
      elsif response.code.to_i > 200 && response.code.to_i < 400
        # saving the redirect page to db
        site.response_code = response.code.to_i
        site.base_html = modify_file_urls(response.body,site.url)
        site.comment = ""
        site.status = true
        site.is_http_authenticated = false
        site.save
      else
        site.response_code = response.code.to_i
        site.base_html = modify_file_urls(response.body,site.url)
        site.comment = "Error page returned."
        site.status = false
        site.is_http_authenticated = false
        site.save
      end
    end

    def save_site_content(response, site,sql_query_id)
        site_content = SiteContent.new
        site_content.site_id = site.id
        site_content.data = modify_file_urls(response.body,site.url)
        site_content.response_code = response.code.to_i
        site_content.sql_injection_id = sql_query_id
        unless site_content.save
          puts site_content.errors.full_messages
        end
    end

    # --------  ---------------


    ## --------  http related methods ---------------

    def get_response(url)
      uri = URI.parse(url)
      http = get_http(uri)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      response
    end

    def get_response_with_cookie(url,cookie)
      uri = URI.parse(url)
      http = get_http(uri)
      request = Net::HTTP::Get.new(uri.request_uri)
      #injection cookie to the request
      request['cookie'] = cookie
      response = http.request(request)
      response
    end

    def get_response_with_parameters(uri,parameters,cookie)
      http = get_http(uri)
      request = Net::HTTP::Post.new(uri.request_uri)
      #injection cookie to the request
      request['cookie'] = cookie
      # posting form values
      request.set_form_data(parameters)
      response = http.request(request)
      response
    end

    def get_response_with_windows_auth(uri,cookie,username,password)
      http = get_http(uri)
      request = Net::HTTP::Get.new(uri.request_uri)
      #injection cookie to the request
      request['cookie'] = cookie
      request_basic_auth(username,password)
      response = http.request (request)
      response
    end

    def get_http(uri)
      http = Net::HTTP.new(uri.host,uri.port)
      # if is secured site
      if uri.scheme.to_s.downcase == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http
    end

    # --------  ---------------


    ## --------  Nokogiri related methods ---------------

    def modify_file_urls(html,url)
      uri = URI.parse(url)
      doc = Nokogiri::HTML(html)
      doc.xpath('//link').each do |link|
        set_path(link,'href',uri)
      end
      doc.xpath('//a').each do |img|
        set_path(img,'href',uri)
      end
      doc.xpath('//script').each do |script|
        set_path(script,'src',uri)
      end
      doc.xpath('//img').each do |img|
        set_path(img,'src',uri)
      end
      doc.to_s.html_safe
    end

    def set_path(element,attribute,uri)
      path = element.attr(attribute)
      unless path.nil?
        if path.to_s.index("/") == 0
          element.set_attribute(attribute, uri.scheme + "://" + uri.host + ":" + uri.port.to_s + path)
        elsif path.to_s.index("http") == 0
        else
            if uri.path.index("/") == 0
              element.set_attribute(attribute, uri.scheme + "://" + uri.host + ":" + uri.port.to_s + uri.path + "/" + path)
            else
              element.set_attribute(attribute, uri.scheme + "://" + uri.host + ":" + uri.port.to_s + "/" + uri.path + "/" + path)
            end
        end
      end
    end

    # --------  ---------------


    ## -------- utility methods ---------------

     def random_string(len)
      #generat a random password consisting of strings and digits
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      newpass = ""
      1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
      newpass
     end

    # --------  ---------------

end


