# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
    require 'simple-json'
    require 'digest/md5'     
    require 'uri'
    include MyEncrypt
    $KCODE = "UTF"
     
     @@solt='softbrain'
     
  #dev
     @@apikey='34facb2d098b050e267ab477ca98bd8e'
     @@sec= Digest::MD5.hexdigest('b7526e7a93ef093a1d100616b4d907f9')
     
  #real
     #@@apikey='e70c7c17e8eb5f501539a8aac88909c2'
     #@@sec= Digest::MD5.hexdigest('206984f759bc6db12d60fde513dc213c')
     
      before_filter :put_session_login
      def put_session_login
         session[:login]= decrypt(params[:login],'softbrain') if params[:login] !=nil
      end

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'c8c944c910ad15aabcc4acb4901a65f8'
   
   
    def auth
      #リンク元のアドレスを格納
      #redirect_add=URI.encode(params[:redirect_add].tosjis,"^_.!~*'()-;/?:@&=+$,\[]") #if params[:redirect_add]
      redirect_add = URI.escape(params[:redirect_add])
     
      #real
      #redirect_to 'http://d0069/auth_api/auth?apikey=' + @@apikey + '&secret=' + @@sec + '&redirect_add=' + redirect_add
      #dev
      redirect_to 'http://localhost:3001/auth_api/auth?apikey=' + @@apikey + '&secret=' + @@sec + '&redirect_add=' + redirect_add
      return
    end
    
    
    def get_auth_info
        parser = JsonParser.new
        @response = nil
        cert = params[:cert]
       
       #real
        #Net::HTTP.start('d0069',80) {|http|
        #    @response = http.get('http://d0069/auth_api/json?apikey=' + @@apikey +'&secret=' + @@sec + '&cert=' + cert)
        #    }
       #dev
         Net::HTTP.start('localhost',3001) {|http|
            @response = http.get('http://localhost:3001/auth_api/json?apikey=' + @@apikey +'&secret=' + @@sec + '&cert=' + cert)
             }
               
       #This enc is encrypted login name ,so it is essential parameter.
       enc = encrypt(parser.parse(@response.body[1,@response.body.size-2])['login'], @@solt) 
       
       redirect_add = URI.escape(params[:redirect_add])
       
      if params[:redirect_add].index("?") then
         redirect_to  redirect_add  + '&login=' + enc
      else
         redirect_to  redirect_add  + '?login=' + enc
      end 
      
    end 
   
    def logout
      reset_session
      redirect_to  bkmafolders_path
    end
    
    def logout_login
     reset_session
     #dev
     redirect_to "http://localhost:3001/user/logout"
     #real
     #redirect_to "http://d0069/user/logout"
     
    end

end
