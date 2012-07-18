class SignupsController < ApplicationController
  layout 'blog' 
  
  def index
    
  end
  
  def new
    if Chargify::Subscription.find(params[:subscription_id])
      session[:signup_subscription_id] = params[:subscription_id]
    end
  end
  
  def basic
    redirect_to "https://ccro.chargify.com/h/1601884/subscriptions/new"
  end
  
  def pro
    redirect_to "https://ccro.chargify.com/h/1601881/subscriptions/new"
  end
  
  def create
    subscription = Chargify::Subscription.find(session[:signup_subscription_id].to_i)
    
    #Create User
    user = Person.create(:first_name => subscription.customer.attributes[:first_name],
                  :last_name => subscription.customer.attributes[:last_name],
                  :password => params[:password],
                  :password_confirmation => params[:password_confirmation],
                  :email => subscription.customer.attributes[:email]
                  )
    
    #Create Suscription linked to above user
    Subscription.create(owner: user, payment_method: 'chargify', payment_id: session[:signup_subscription_id], product: subscription.product.attributes[:accounting_code] , active: true )
    
    #send validation email
    user.send_activation
    AdminMailer.signup_complete(user, cookies[:url_after_signup]).deliver

    render text: "We have sent you a confirmation email!"
  end
end
