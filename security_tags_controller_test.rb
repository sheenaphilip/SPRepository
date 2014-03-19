require File.dirname(__FILE__) + '/../../test_helper'

class Axiom::SecurityTagsControllerTest < ActionController::TestCase
  setup do
    @user = axiom_users(:CorpAppQAUsr)
    @security_tag = axiom_security_tags(:Axiom_MySecurityTag)
  end

  def stub_call(result, errors, json, method)
    stub_web_service_response(result, errors, json)
    Axiom::SecurityTagManager.any_instance.stub(method).and_return(@web_svc_response)
  end

  def cleanup_stub(method)
    Axiom::SecurityTagManager.any_instance.unstub(method)
  end

  test "should get index" do
    #Set up session values to skip authentication
    session[:remember_token] = @user.session_id
    session[:user_id] = @user.user_id
    session[:expires_at] = ENV['SESSION_TIMEOUT'].to_i.minutes.from_now
    session[:goback_to] = "/#{I18n.locale}/axiom/security_tags"
    #Make the GET request
    get :index
    #Assert we got a 200 OK response
    assert_response :success
    #Make sure initialize_search_session() worked
    assert_equal session[:search_text], ''
    assert_equal session[:audit_flag], I18n.t('all')
    assert_equal session[:active_flag], I18n.t('all')
    assert_equal session[:business_owner], I18n.t('all')
    #Make sure load_security_tags() worked
    assert(security_tags_loaded,"Security Tags not loaded" )
    assert(Axiom::SecurityTag.count > 0 ,"SecurityTag is not greater than 0")
    #Make sure load load_business_owners() worked
    assert_not_nil assigns(:business_owners)
    assert_not_nil session[:business_owners]
    assert_equal session[:business_owners].first, I18n.t('all')
  end

  test "should post search with no filter" do
    session[:remember_token] = @user.session_id
    session[:user_id] = @user.user_id
    session[:expires_at] = ENV['SESSION_TIMEOUT'].to_i.minutes.from_now
    session[:goback_to] = "/#{I18n.locale}/axiom/security_tags"
    @controller.send(:load_business_owners)
    post :search, {search_text: "", search_descr_text: "", business_owner: "All", active_flag: "All", audit_flag: "All"}
    assert_response :success
    assert_equal "", assigns(:filter)
  end

  test "should post search with filter" do
    session[:remember_token] = @user.session_id
    session[:user_id] = @user.user_id
    session[:expires_at] = ENV['SESSION_TIMEOUT'].to_i.minutes.from_now
    session[:goback_to] = "/#{I18n.locale}/axiom/security_tags"
    @controller.send(:load_business_owners)
    post :search, {search_text: 'job', search_descr_text: 'add a job', business_owner: 'jbutler', active_flag: 'True', audit_flag: 'False'}
    assert_response :success
    assert_equal "audit_flag = 'False' and active_flag ='True' and LOWER(security_tag) like LOWER('%job%') and LOWER(description) like LOWER('%add a job%') and business_owner ='jbutler'", assigns(:filter)
  end

  test "New security tag" do
    session[:remember_token] = @user.session_id
    session[:user_id] = @user.user_id
    session[:expires_at] = ENV['SESSION_TIMEOUT'].to_i.minutes.from_now
    session[:goback_to] = "/#{I18n.locale}/axiom/security_tags"
    get :new
    assert_response :success
  end
# Test for new security tag creation
  test "Create security tag" do
    session[:remember_token] = @user.session_id
    session[:user_id] = @user.user_id
    session[:expires_at] = ENV['SESSION_TIMEOUT'].to_i.minutes.from_now
    session[:goback_to] = "/#{I18n.locale}/axiom/security_tags"
    stub_call("Success", nil, {result: "Success"}.to_json, :post_security_tag) #webservice method name :post_security_tag

    json_text = {:CBLKSecurityTag264 => {SecurityTagList: "", SecurityTag:"Axiom_Coupon", Description: "Allows access to search and view coupons", BusinessOwner: "lmartin", ActiveFlg: "True", AuditFlg: "True" }.to_json}.to_json
    stub_call("Success", nil,json_text, :get_security_roles_all)
    post :create, axiom_security_tag: {:security_tag => "TestTag1",:description => "TestDescription1",:business_owner => "Test BO1",:audit_flag => "1",:active_flag => "1"}
    assert_redirected_to axiom_security_tag_details_path(active_flag: 1, audit_flag: 1, business_owner: "Test BO1",
                         description: "TestDescription1", security_tag: "TestTag1")
    cleanup_stub(:post_security_tag) #webservice method name :post_security_tag
    cleanup_stub(:get_security_roles_all)
  end

  test "Create invalid security tag" do
    session[:remember_token] = @user.session_id
    session[:user_id] = @user.user_id
    session[:expires_at] = ENV['SESSION_TIMEOUT'].to_i.minutes.from_now
    session[:goback_to] = "/#{I18n.locale}/axiom/security_tags"
    post :create, axiom_security_tag: {:security_tag => " ",:description  => " ",:business_owner => " ",:audit_flag => " ",:active_flag => ""}
    assert_equal assigns(:security_tag).errors.messages[:security_tag][0], "can't be blank"
  end

  test "Show security tag" do
    session[:remember_token] = @user.session_id
    session[:user_id] = @user.user_id
    session[:expires_at] = ENV['SESSION_TIMEOUT'].to_i.minutes.from_now
    session[:goback_to] = "/#{I18n.locale}/axiom/security_tags"
    get(:show,{'id'=> Axiom::SecurityTag.first.id})
    assert_response :success
  end

  #test "should show all security tags" do
  #  session[:remember_token] = @user.session_id
  #  session[:user_id] = @user.user_id
  #  session[:expires_at] = ENV['SESSION_TIMEOUT'].to_i.minutes.from_now
  #  session[:goback_to] = "/#{I18n.locale}/axiom/security_tags"
  #  @controller.send(:load_business_owners)
  #  session[:business_owner] = I18n.translate('all')
  #  session[:filter] = ""
  #
  #  get :show
  #  assert_response :success
  #end

end
