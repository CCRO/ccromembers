class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :check_browser

  before_filter :store_location

  before_filter :set_mailer_host
  
  before_filter :http_basic_authentication
  
  before_filter :cookie_authentication
  
  before_filter :activation_authentication
  
  before_filter :set_cache_buster

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
  end

  def check_browser
    browser = Browser.new(:ua => request.env['HTTP_USER_AGENT'], :accept_language => "en-us")

    redirect_to hell_path if (browser.ie6?) && params[:controller] != 'static'
    logger.info "Browser Status: #{request.env['HTTP_USER_AGENT']}  =>  #{browser.to_s}"
  end

  # Collect additional debug details for New Relic RPM is available
  # Do this after all other before filters so details are present
  before_filter :set_new_relic_custom_parameters
  def set_new_relic_custom_parameters
    return unless defined?(NewRelic)
    NewRelic::Agent.add_custom_parameters(
      :locale => (I18n.locale if I18n.locale),
      :account => (current_user ? current_user.email : 'guest'),
      :return_to => (session[:url_return_to] if session[:url_return_to]),
      :return_to_login => (session[:url_after_login] if session[:url_after_login])
    )
  end
  private :set_new_relic_custom_parameters
  
  def set_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
  
  private
  
  def store_location
    unless params[:controller] == "sessions" || params[:controller] == "people" || params[:controller] == "exceptions"
      session[:url_after_login] = request.url unless current_user || request.url == new_sessions_url
      session[:url_return_to] = request.url if !request.xhr? && (request.path != "/login" && request.path != "/register")
      logger.info 'Session: ' + session.to_s
    end
  end

  def redirect_back_or_default(default, *options)
    if session[:url_return_to].present?
      logger.info "Redirecting back to url_return_to: " + session[:url_return_to]
      redirect_to(session[:url_return_to], *options)
    else
      logger.info "Redirecting back to default: " +  default
      redirect_to(default, *options)
    end
    #logger.info "Redirecting back to: " + session[key] || default
    session[:url_return_to] = nil
  end
    
  def is_editing?
    params[:action] == 'edit'
  end
  helper_method :is_editing?
     
  def current_user
    current_user ||= Person.find_by_id(session[:su_user_id]) if session[:su_user_id]
    current_user ||= Person.find_by_id(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def default_company
    Company.find_by_role('administrator')
  end
  helper_method :default_company
  
  def require_user
    redirect_to login_url, :flash => {:error => t(:no_user_flash)} if current_user.nil?
  end

  def require_no_user
    redirect_to dashboard_path, :flash => {warning: "This action is not avialable to already logged in users."} if current_user
  end

  def require_admin
    redirect_to dashboard_path,:flash => {error: "Not authorized." } unless current_user && current_user.admin?
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    if current_user && current_user.admin?
      redirect_to exceptions_accessdenied_path(), :alert => "The thing you are trying to get to does not seem to exist: #{exception}"
    else
      redirect_to exceptions_accessdenied_path(), :alert => "The thing you are trying to get to does not seem to exist"
    end
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    session[:access_denied_return_url] = request.url
    subject = exception.subject.attributes.delete_if { |key,value| value.to_s.length > 128 } if exception.subject.class.name == 'Post'
    session[:access_denied_subject] = subject
    redirect_to exceptions_accessdenied_path(), :alert => exception.message

    # case exception.subject.class.name
    # when 'Post'
    #   logger.info 'EXCEPTION: ' + exception.subject.class.name + exception.to_json
    #   message = "<br><br>To read the article entitled \"#{exception.subject.title}\". You must have #{exception.subject.level} subscription.<br><br>" 
    #   redirect_to forbidden_path(), :flash => {error: (exception.message + message).html_safe }
    # else
    #   redirect_to forbidden_path(), :flash => {error: exception.message }
    # end
  end
  
  protected

  def http_basic_authentication
    if !current_user && (request.format == Mime::XML || request.format == Mime::JSON)
      authenticate_or_request_with_http_basic do |username, password|
        login_user(Person.find_by_access_token(username)) if Person.find_by_access_token(username)
      end
    end
  end
  
  def cookie_authentication
    if !current_user && cookies[:auth_token]
      login_user(Person.find_by_auth_token(cookies.signed[:auth_token])) if Person.find_by_auth_token(cookies.signed[:auth_token])
      if current_user
        current_user.generate_token!
        cookies.permanent.signed[:auth_token] = current_user.auth_token
      end
    end
  end
  
  def activation_authentication
    if params[:activation_token]
      user = activate_user(Person.find_by_perishable_token(params[:activation_token])) if Person.find_by_perishable_token(params[:activation_token])
      login_user(user)
      if current_user
        params[:id] = user.id
        cookies.permanent.signed[:auth_token] = current_user.auth_token
      end
    end
  end
  
  def activate_user(person)
    if person
      person.generate_token!
      person.verified = true
      person.save
      person
    end
  end

  def login_user(person)
    if person
      session[:user_id] = person.id if person.verified
    end
  end

  def all_tags
    ActsAsTaggableOn::Tag.all.each
  end

  def radio_question_responses(question, response)
    temp = []
    response_people = []
    temp = Response.where(question_id: question, selected_response: response).to_a

    temp.each do |t|
      unless Person.find(t.person_id).admin?
        response_people << Person.find(t.person_id)
      end
    end
    
    return response_people
  end 

  def checkbox_question_responses(question, key)
    temp = []
    response_people = []
    all_responses = []
    temp = Response.where(question_id: question)

    temp.each do |t|
      unless Person.find(t.person_id).admin?
        all_responses << t
      end
    end
    
    all_responses.each do |r|
      if r.selected_responses[key.to_i] == 1
        response_people << Person.find(r.person_id)
      end
    end

    return response_people
  end 
  
end
