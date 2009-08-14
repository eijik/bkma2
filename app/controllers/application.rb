# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
    require 'simple-json'
    require 'digest/md5'     
    require 'uri'
    include MyEncrypt
    $KCODE = "UTF"
     
     
      before_filter :session_login
      def session_login
        if params["openid.claimed_id"] && session[:login_no] == nil  then
        
           #session[:identity_url] = params["openid.claimed_id"] 
           login_name ||= params["openid.sreg.nickname"] 
           login_name ||= params["openid.ext1.value.ext0"] 
           login_name ||="NoName"

           unless @user = User.find_by_identity_url(params["openid.claimed_id"])
              @user = User.new
              @user.login = login_name
              @user.identity_url = params["openid.claimed_id"] 
              @user.save
            end
            session[:login_no]=@user.id
            
          if  login_name !="NoName" then
              @user = User.find(session[:login_no])
              @user.update_attributes(:login=>login_name)
          end
            
        end
      end

  helper :all # include all helpers, all the time

  protect_from_forgery # :secret => 'c8c944c910ad15aabcc4acb4901a65f8'
   
    def auth
     if using_open_id?
        open_id_authentication
      else
        flash[:notice] = "failed login!"
        redirect_to :back
      end
    end
    
    def logout
      reset_session
      redirect_to  bkmafolders_path
    end
    
    protected

      def open_id_authentication
        authenticate_with_open_id(params[:openid_url],:return_to => params[:redirect_add],:required => params[:require]) do |result, identity_url,registration|
         if result.successful?
            successful_login
          else
            failed_login result.message
          end
        end
      end
    
    
    private
      def successful_login
        flash[:notice] = "got login!!! #{session[:login]}"
         redirect_to bkmafolders_path
      end

      def failed_login(message)
        flash[:notice]= message
        redirect_to bkmafolders_path
      end

end
