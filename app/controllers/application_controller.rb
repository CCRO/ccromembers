class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :store_location

  before_filter :set_mailer_host
  
  before_filter :http_basic_authentication
  
  # Collect additional debug details for New Relic RPM is available
  # Do this after all other before filters so details are present
  before_filter :set_new_relic_custom_parameters
  def set_new_relic_custom_parameters
    return unless defined?(NewRelic)
    NewRelic::Agent.add_custom_parameters(
      :locale => (I18n.locale if I18n.locale),
      :account => (current_user ? current_user.email : 'guest'),
      :return_to => (session[:url_return_to] if session[:url_return_to]),
      :return_to => (session[:url_after_login] if session[:url_after_login])
    )
  end
  private :set_new_relic_custom_parameters
  
  def set_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
  
  private
  
  def store_location
    unless params[:controller] == "sessions"
      session[:url_after_login] = request.url unless current_user || request.url == new_sessions_url
      session[:url_return_to] = request.url if !request.xhr? && request.path != "/login"
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
    params[:mercury_frame]
  end
  helper_method :is_editing?
     
  def current_user
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
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to forbidden_path(), :flash => {error: exception.message }
  end
  
  protected

  def http_basic_authentication
    if !current_user && (request.format == Mime::XML || request.format == Mime::JSON)
      authenticate_or_request_with_http_basic do |username, password|
        session[:user_id] ||= Person.find_by_access_token(username).id if Person.find_by_access_token(username)
      end
    end
  end
end
