include Axiom::SecurityTagsHelper
include Axiom::BaseHelper

class Axiom::SecurityTagsController < Axiom::BaseController
  filter_access_to :all, :context => :security_tags
  # GET /security_tags
  # GET /security_tags.json
  require 'will_paginate/array'

  def index
    Rails.logger.debug "ENTERING security_tags_controller_index..."

    if params[:commit]
      search
    else
      initialize_search_session()
      load_business_owners()
      load_security_tags()
      @security_tags = Axiom::SecurityTag.all.paginate(per_page: 15, page: params[:page])
    end


    if security_tags_loaded
      respond_to do |format|
        format.html # index.html.erb
        #format.json #{ render json: @security_tags }
      end
    end

  end

  def search


    if check_current_business_owner_locale()
        load_business_owners()
    end

    @filter = get_search_filter()
    if load_security_tags()
      @security_tags = Axiom::SecurityTag.where(@filter).paginate(per_page: 15, page: params[:page])

      session[:filter] = @filter
      session[:search_text] = params[:search_text]
      session[:search_descr_text] = params[:search_descr_text]
      session[:audit_flag] = params[:audit_flag]
      session[:active_flag] = params[:active_flag]
      session[:business_owner] = params[:business_owner]

      @business_owners = session[:business_owners]
      #respond_to do |format|
      #  format.html
      #  format.json { render json: @security_tags }
      #end
    end
  end
  # GET /security_tags/1
  # GET /security_tags/1.json
  #def show
  #  #if session[:filter].nil?
  #  #  return redirect_to '/axiom/security_tags'
  #  #end
  #  if check_current_business_owner_locale()
  #    load_business_owners()
  #  end
  #  @filter = session[:filter]
  #  @security_tags = Axiom::SecurityTag.where(@filter).paginate(per_page: 15, page: params[:page])
  #  @business_owners = session[:business_owners]
  #  respond_to do |format|
  #    format.html # show.html.erb
  #    format.json { render json: @security_tags }
  #  end
  #end

  def initialize_search_session
    session[:search_text] = ''
    session[:search_descr_text] = ''
    session[:audit_flag] = t('all')
    session[:active_flag] = t('all')
    session[:business_owner] = t('all')
  end

  def load_business_owners
    @business_owners = Axiom::SecurityTag.all.map!(&:business_owner).uniq
    @business_owners = @business_owners.sort
    @business_owners.unshift(t('all'))
    session[:business_owners] = @business_owners
  end

  def get_search_filter

    @filter = ""

    if params[:audit_flag] != 'All'
      @filter =  "audit_flag = '"+params[:audit_flag]+"' "
    end

    if params[:active_flag] != 'All'
      if @filter == ""
        @filter =  "active_flag ='"+params[:active_flag]+"' "
      else
        @filter = @filter + "and active_flag ='"+params[:active_flag]+"' "
      end

    end


    if params[:search_text] != ""
      if @filter == ""
        @filter =   "LOWER(security_tag) like LOWER('%"+params[:search_text]+"%') "
      else
        @filter = @filter + "and LOWER(security_tag) like LOWER('%"+params[:search_text]+"%') "
      end

    end

    if params[:search_descr_text] != ""
      if @filter == ""
        @filter =   "LOWER(description) like LOWER('%"+params[:search_descr_text]+"%') "
      else
        @filter = @filter + "and LOWER(description) like LOWER('%"+params[:search_descr_text]+"%') "
      end

    end

    if ! translates_to('all', params[:business_owner])
      if @filter == ""
        @filter =   "business_owner ='" +params[:business_owner]+"'"
      else
        @filter = @filter + "and business_owner ='" +params[:business_owner]+"'"
      end

    end

    @filter

  end

  def new
  #  load_security_tags()
  #  load_business_owners()
   # @business_owners.delete(I18n.translate('all'))
    @security_tag = Axiom::SecurityTag.new
    respond_to do |format|
      format.html # index.html.erb
      #format.json #{ render json: @security_tags }
    end
  end

  def create
   #@security_tag = Axiom::SecurityTag.new(params[:axiom_security_tag])
   @security_tag = (params[:axiom_security_tag])

    @security_tag_hash = Hash.new()

    @security_tag_hash = {'SecurityTag' => params[:axiom_security_tag][:security_tag],
                          'Description' =>  params[:axiom_security_tag][:description],
                          'ActiveFlag' => params[:axiom_security_tag][:active_flag],
                          'AuditFlag' => params[:axiom_security_tag][:audit_flag],
                          'BusinessOwner' => params[:axiom_security_tag][:business_owner]}
    respond_to do |format|
     # if @security_tag.save

        res = create_security_tag(@security_tag_hash.to_json)
        session[:security_tags_loaded] = false
        load_security_tags()
        security_tag_created = Axiom::SecurityTag.find_by_security_tag(params[:axiom_security_tag][:security_tag])

        format.html { redirect_to axiom_security_tag_details_path(:security_tag => security_tag_created.security_tag, :description => security_tag_created.description, :audit_flag => security_tag_created.audit_flag, :business_owner => security_tag_created.business_owner, :active_flag => security_tag_created.active_flag),notice: 'Security Tag was successfully created.' }
       # format.json { render action: 'show', status: :created, location: @security_tag }

        #else
          #format.html { render action: 'new' }
         # format.json { render json: @security_tag.errors, status: :unprocessable_entity }
       # end

         end
  end

  def show
    @security_tag = Axiom::SecurityTag.find(params[:id])

  end


end
