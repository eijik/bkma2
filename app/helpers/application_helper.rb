# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  require 'uri'
  include MyEncrypt

  def h_decrypt
    decrypt(params[:login],'softbrain')
  end

  def h_login
    session[:login]= h_decrypt if params[:login] !=nil
    
    unless session[:login]  then
     "ログインしていません。"
    else
     "ようこそ" +"<span id='login-name'>"+ session[:login]  + "</span>" + "さん。"  # + "ログアウトするときは" + link_to('こちら', :controller=>"logout",:redirect_add =>'/bkma' + request.path) + "から。" 
    end 
  end
   
   
  def h_login_button_up
    session[:login]= h_decrypt if params[:login] !=nil
    
    unless session[:login]  then
      link_to(image_tag("/images/login_button.png",:size=>"100x35"),:controller=>"auth" ,:redirect_add =>$prefix + request.path) 
    else
      #image_tag("/images/login_button.png",:size=>"100x35") 
    end
  end

  def h_login_button_down
    session[:login]= h_decrypt if params[:login] !=nil
    
    unless session[:login]  then
      #image_tag("/images/logout_button.png",:size=>"100x35")
    else
      link_to(image_tag("/images/logout_off_button.png",:size=>"100x35"),:controller=>"logout_login",:redirect_add =>$prefix + request.path) 
    end
  end


  
  #引数に渡す単位はbkmafoderに登録されているブックマークオブジェクト(第一引数のインスタンスはBkmafoldersモデルクラスがベース)
  def h_each_other_comment(bkmafolder_1bkma,user_name,rev_flg,title = "")
     i=0
     tag = []
     tags =""
     comment=""
     
     if rev_flg != 1 then
  	    for comment_row in bkmafolder_1bkma.urllist.comment 
	         if user_name == comment_row.login then 
		          if comment_row.tag_flg == 1  then   
		               tag <<  h_encoding_tag_link(comment_row.comment,true,comment_row.login)
		          else
                   comment = comment + "," if  i !=0 
                   comment = comment + comment_row.comment
                   i=1 
              end 
            end 
        end 
      else
        for comment_row in bkmafolder_1bkma.urllist.comment 
	         if user_name != comment_row.login then 
		          if comment_row.tag_flg == 1  then   
		               tag <<  h_encoding_tag_link(comment_row.comment,true)#,comment_row.login)
		          else
                   comment = comment + ", " if  i !=0 
                   comment = comment + comment_row.comment
                   i=1 
              end 
            end 
        end 
      end
        #重複タグは一元化する
        tags =  tag.uniq.join
        comment = "<b>"+title+"</b>" + tags + comment
        return comment
  end
  
  #引数に渡す単位はbkmafoderに登録されているブックマークオブジェクト(第一引数のインスタンスはUrllistモデルクラスがベース)
  def h_each_other_comment_U(bkmafolder_1bkma,user_name,rev_flg,title = "")
     i=0
     tag = []
     tags =""
     comment=""
     
     if rev_flg != 1 then
  	    for comment_row in bkmafolder_1bkma.comment 
	         if user_name == comment_row.login then 
		          if comment_row.tag_flg == 1  then   
		               tag <<  h_encoding_tag_link(comment_row.comment,true,comment_row.login)
		          else
                   comment = comment + "," if  i !=0 
                   comment = comment + comment_row.comment
                   i=1 
              end 
            end 
        end 
      else
        for comment_row in bkmafolder_1bkma.comment 
	         if user_name != comment_row.login then 
		          if comment_row.tag_flg == 1  then   
		               tag <<  h_encoding_tag_link(comment_row.comment,true)
		          else
                   comment = comment + ", " if  i !=0 
                   comment = comment + comment_row.comment
                   i=1 
              end 
            end 
        end 
      end
        #重複タグは一元化する
        tags =  tag.uniq.join
        comment = "<b>"+title+"</b>" + tags + comment
        return comment
  end


  def h_encoding_tag_link(encode_link,tag_flg,title = "")
     if tag_flg then
       return  "[" + link_to(encode_link,tag_path(h_uri_encode(encode_link)),:title=>title) + "] " 
     else
       return   link_to(encode_link,tag_path(h_uri_encode(encode_link)),:title=>title) 
     end
  end
  
  def h_check_path
      link_to(image_tag("/images/nav_reg.png",:size=>"80x80"),urllist_path(:check))  +  image_tag("/images/nav_bar.png")if session[:login]  and check_urllists_path != request.path  
  end
  
  def h_everyone_path
      link_to(image_tag("/images/nav_mybookmark.png",:size=>"80x80"),bkmafolder_path(h_uri_encode(session[:login])))  +  image_tag("/images/nav_bar.png")if session[:login]  and bkmafolder_path(h_uri_encode(session[:login])) != request.path  
  end  
  
  
  def h_uri_encode(encode_link)
    return URI.encode(encode_link,"^_.!~*'()-;/?:@&=+$,\[]") if encode_link
  end
  
end
