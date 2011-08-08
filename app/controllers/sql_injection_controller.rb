require "nokogiri"
require "open-uri"
require 'net/http'
require 'net/https'
require "uri"
require "sqlinjection"
require "unicorn"

class SqlInjectionController < ApplicationController
                      include Sql_injection_module
  def inject
    test = nil
    unless params[:siteurl].nil?
      @site = Site.new
      @site.url = params[:siteurl].to_s

      begin
           uri = URI.parse(params[:siteurl])
          test = uri.request_uri
      rescue
      end
      if test.nil?
        @error = "Please enter full url."
        render :check
        return
      end


      if @site.save
       # getting root url
        unless @site.is_it_root
          @site.url = get_root_site_url(@site.url)
          @site.is_it_root = true
          @site.save
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
        redirect_to "/sql_injection/list/" + @site.id.to_s
        return
      else
          render :check
          return
      end
    else
        redirect_to :action => "check"
    end
  end

  def check
    @error = ""
    @site = Site.new
  end

  def list
    unless params[:siteid].nil?
      @site = Site.find_by_id(params[:siteid].to_i)
      unless @site.nil?
        @sit_content = SiteContent.find_all_by_site_id(@site.id)
        if @sit_content.nil? || @sit_content.count == 0
          redirect_to :controller => "sql_injection", :action => "check"
        end
        render :stream => true
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
