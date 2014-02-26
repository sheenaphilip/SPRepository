include Axiom::SecurityTagDetailsHelper
include Axiom::SecurityTagsHelper

class Axiom::SecurityTagDetailsController < Axiom::BaseController
  filter_access_to :all, :context => :security_tag_details
  #require 'will_paginate/array'

  def index
    if (Axiom::Employee.where(:session_id => session[:remember_token]).count == 0) ||
        (session[:security_tag] !=  params[:security_tag] )
        security_mgr = Axiom::SecurityTagManager.new()
        security_mgr.web_svc_url = @web_svc_url
        load_session
        res = security_mgr.get_security_tag_details(params[:security_tag])
        unless verify_httparty_response(res)
          return redirect_to '/axiom/errors'
        end
        resdecode = ActiveSupport::JSON.decode(res['ReturnValueJSON'])
        build_security_tag_details(resdecode)
    end

    #Make sure we are displaying correct translation for business_owner
    check_current_business_owner_locale

    @area_groups = Axiom::AreaGroup.where(:session_id => session[:remember_token])
    if params[:tag_type] == 'JobFamily'
      @job_families = Axiom::JobFamily.where(:session_id => session[:remember_token]).paginate(per_page: 15, page: params[:page])
    else
      @job_families = Axiom::JobFamily.where(:session_id => session[:remember_token]).paginate(per_page: 15, page: 1)
    end

    @teams = Axiom::Team.where(:session_id => session[:remember_token])

    if params[:tag_type] == 'CostCenter'
      @cost_centers = Axiom::CostCenter.where(:session_id => session[:remember_token]).paginate(per_page: 15, page: params[:page])
    else
      @cost_centers = Axiom::CostCenter.where(:session_id => session[:remember_token]).paginate(per_page: 15, page: 1)
    end


    if params[:tag_type] == 'Individual'
      @employees = Axiom::Employee.where(:session_id => session[:remember_token]).paginate(per_page: 15, page: params[:page])
    else
      @employees = Axiom::Employee.where(:session_id => session[:remember_token]).paginate(per_page: 15, page: 1)
    end


    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json #{ render json: @security_tags }
    end
  end

end
