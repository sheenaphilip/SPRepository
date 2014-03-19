include Axiom::SecurityTagsHelper
include Axiom::BaseHelper

class Axiom::SecurityTagsController < Axiom::BaseController
  filter_access_to :all, :context => :security_tags
  # GET /security_tags
  # GET /security_tags.json
  require 'will_paginate/array'
  before_filter :check_for_cancel

  def check_for_cancel
    unless params[:cancel].blank?
      redirect_to '/axiom/security_tags'
    end
  end

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
    end
  end

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
    @security_tag = Axiom::SecurityTag.new
    respond_to do |format|
      format.html # index.html.erb
      #format.json #{ render json: @security_tags }
    end
  end

  def create

      @security_tag = Axiom::SecurityTag.new(params[:axiom_security_tag])
      @security_tag_hash = Hash.new()

      @security_tag_hash = {'SecurityTag' => params[:axiom_security_tag][:security_tag],
                            'Description' =>  params[:axiom_security_tag][:description],
                            'BusinessOwner' => params[:axiom_security_tag][:business_owner],
                            'ActiveFlag' => params[:axiom_security_tag][:active_flag],
                            'AuditFlag' => params[:axiom_security_tag][:audit_flag],
      }

      respond_to do |format|
        if  @security_tag.valid?
          res = create_security_tag(@security_tag_hash.to_json)
          unless verify_httparty_response(res)
          return redirect_to '/axiom/errors'
          end
          session[:security_tags_loaded] = false
          load_security_tags()
          format.html { redirect_to axiom_security_tag_details_path(params[:axiom_security_tag]), notice: 'Security Tag was successfully created.' }
        else
          format.html { render action: 'new' }
          format.json { render json: @security_tag.errors, status: :unprocessable_entity }

        end

      end


  end

####
  def edit
    @security_tag = current_user.axiom_security_tag.find(params[:id])
    @security_tag = Axiom::SecurityTag.new(params[:axiom_security_tag])
  end

  def update
    @security_tag = current_user.security_tag.find(params[:id])
    if @security_tag.update_attributes(params[:security_tag])
      flash[:notice] = 'Security Tag was successfully updated.'
      redirect_to(@security_tag)
    else
      render "edit"
    end
  end

###
  def show
    @security_tag = Axiom::SecurityTag.find(params[:id])
  end

 end
