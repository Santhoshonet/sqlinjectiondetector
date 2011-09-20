require "nokogiri"
require "open-uri"
require 'net/http'
require 'net/https'
require "uri"
require "sqlinjection"
#require "unicorn"
require "diff"
require "xmlsimple"
class SqlInjectionController < ApplicationController
                      include Sql_injection_module
  def inject
    test = nil
    unless params[:SiteURL].nil?
      @site = Site.new
      @site.url = params[:SiteURL].to_s
      begin
           uri = URI.parse(params[:SiteURL])
          test = uri.request_uri
      rescue
      end
      if test.nil?
        @error = "Please enter full url."
        redirect_to :action => "check"
        #render :check
        return
      end
      if @site.save
        begin
          # getting root url
          unless @site.is_it_root
            @site.url = get_root_site_url(@site.url)
            @site.is_it_root = true
            @site.save
          end
        rescue
          @error = "Something wrong happened at the server, please check the url and submit again."
          #render :check
          redirect_to :action => "check"
          return
        end
        #if site.status == false
        get_base_content(@site)
        #end
        #Delayed::Job.enqueue(SqlinjectionLib.new(@site))
        system "rake injection[#{@site.id}]  --trace &"
=begin
        SqlInjectionQuery.all.each do |sql_injection_query|
          doc = Nokogiri::HTML(open(@site.url))
          doc.xpath('//form').each do |form|
            response = get_http_response(form,sql_injection_query.query,@site)
            save_site_content(response,@site,sql_injection_query.id)
          end
        end
=end
        #redirect_to "/sql_injection/list/" + @site.id.to_s
        redirect_to "/sql_injection/processing/" + @site.id.to_s
        return
      else
          #render :check
          redirect_to :action => "check"
          return
      end
    else
        redirect_to :action => "check"
        return
    end
  end

  def processing
    unless params[:siteid].nil?
        @total = SqlInjectionQuery.count()
    else
        redirect_to :action => "check"
    end
  end

  def status
    count = 0
    unless params[:siteid].nil?
      count   = SiteContent.find_all_by_site_id(params[:siteid]).count() - 1
    end
    render :text => count
  end

  def analysis
    @total = SqlInjectionQuery.count()
    @result = []
    search_keywords = ["signed in successfully.","log out", "sign out", "logout", "signout"]
    unless params[:siteid].nil?
      site = Site.find_by_id(params[:siteid])
      unless site.nil?
        base_content = site.base_html
        SiteContent.find_all_by_site_id(site.id).each do |site_content|
          begin
            doc = Nokogiri::HTML(site_content.data)
            response = Hash.from_xml(doc)
            doc = Nokogiri::HTML(base_content)
            expected = Hash.from_xml(doc)
            if expected.diff(response).count() > 0
              @result.append("Expected results not found, Something wrong happening in your site.")
            end
            expected.diff(response).each do |diff|
              puts diff
            end
          rescue
          end
          begin
            doc = Nokogiri::XML(site_content.data)
            hash_site_content = XmlSimple.xml_in(doc.to_s)
            doc = Nokogiri::XML(base_content)
            hash_base_content = XmlSimple.xml_in(doc.to_s)
            diff = Diff.new(hash_site_content,hash_base_content)
            if diff.count() > 0
              @result.append("Expected results not found, Something wrong happening in your site.")
            end
            diff.diffs.each do |dif|
                puts dif
            end
          rescue
          end
          if site_content.response_code != site.response_code
            if site_content.response_code > 400
              @result.push "Site has been redirected to error page, errors and error page should be fixed. "
            elsif site_content.response_code > 300
              @result.push "Site has been redirected to another page, It might be wrong."
            end
          else
            search_keywords.each do |keyword|
              if site_content.data.include?(keyword)
                @result.push "Invalid keywords found in the page, please check your database queries."
              end
            end
          end
        end
      end
    end
  end

  def check
    @error = ""
    @site = Site.new
    @site.url = "SiteURL"
  end

  def list
    unless params[:siteid].nil?
      @site = Site.find_by_id(params[:siteid].to_i)
      unless @site.nil?
        @sit_content = SiteContent.find_all_by_site_id(@site.id)
        if @sit_content.nil? || @sit_content.count == 0
          redirect_to :controller => "sql_injection", :action => "check"
        end
      else
        redirect_to :action => "check"
      end
    else
      redirect_to :action => "check"
    end
  end

  def sitecontent
    unless params[:siteid].nil?
      site_content = SiteContent.find_by_id(params[:siteid].to_i)
      unless site_content.nil?
        render :text => site_content.data
        return
      end
    end
    render :text => "data not found."
  end

end
