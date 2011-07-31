class SitesController < ApplicationController
  # GET /sites
  # GET /sites.xml
  def index
    @sites = Site.all
  end

  # GET /sites/1
  # GET /sites/1.xml
  def show
    @site = Site.find(params[:id])
  end

  # GET /sites/new
  # GET /sites/new.xml
  def new
    @site = Site.new
  end

  # GET /sites/1/edit
  def edit
    @site = Site.find(params[:id])
  end

  # POST /sites
  # POST /sites.xml
  def create
    @site = Site.new(params[:site])
    data = {}
    if @site.save
      data[:status] =  "success"
      data[:id] = @site.id
    else
      @site.errors.each do |key, value|
        data[:status] = value
      end
    end
    render :json => data
  end

  # PUT /sites/1
  # PUT /sites/1.xml
  def update
    @site = Site.find(params[:id])
    if @site.update_attributes(params[:site])
      redirect_to(@site, :notice => 'Site was successfully updated.')
    else
        render :action => "edit" 
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.xml
  def destroy
    @site = Site.find(params[:id])
    @site.destroy
    redirect_to(sites_url) 
  end
end
