class SqlInjectionQueriesController < ApplicationController
  # GET /sql_injection_queries
  # GET /sql_injection_queries.xml
  def index
    @sql_injection_queries = SqlInjectionQuery.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sql_injection_queries }
    end
  end

  # GET /sql_injection_queries/1
  # GET /sql_injection_queries/1.xml
  def show
    @sql_injection_query = SqlInjectionQuery.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sql_injection_query }
    end
  end

  # GET /sql_injection_queries/new
  # GET /sql_injection_queries/new.xml
  def new
    @sql_injection_query = SqlInjectionQuery.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sql_injection_query }
    end
  end

  # GET /sql_injection_queries/1/edit
  def edit
    @sql_injection_query = SqlInjectionQuery.find(params[:id])
  end

  # POST /sql_injection_queries
  # POST /sql_injection_queries.xml
  def create
    @sql_injection_query = SqlInjectionQuery.new(params[:sql_injection_query])

    respond_to do |format|
      if @sql_injection_query.save
        format.html { redirect_to(@sql_injection_query, :notice => 'Sql injection query was successfully created.') }
        format.xml  { render :xml => @sql_injection_query, :status => :created, :location => @sql_injection_query }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sql_injection_query.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sql_injection_queries/1
  # PUT /sql_injection_queries/1.xml
  def update
    @sql_injection_query = SqlInjectionQuery.find(params[:id])

    respond_to do |format|
      if @sql_injection_query.update_attributes(params[:sql_injection_query])
        format.html { redirect_to(@sql_injection_query, :notice => 'Sql injection query was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sql_injection_query.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sql_injection_queries/1
  # DELETE /sql_injection_queries/1.xml
  def destroy
    @sql_injection_query = SqlInjectionQuery.find(params[:id])
    @sql_injection_query.destroy

    respond_to do |format|
      format.html { redirect_to(sql_injection_queries_url) }
      format.xml  { head :ok }
    end
  end
end
