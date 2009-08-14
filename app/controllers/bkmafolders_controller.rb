class BkmafoldersController < ApplicationController

  def index
     @bookmarklists = Bkmafolder.paginate(:all,:page => params[:page],:per_page => 10,:order=>"created_at DESC")
     #@bookmarklists = Bkmafolder.find(:all,:order=>"created_at",:limit=>10)
     
     @bkmafolders = Bkmafolder.find(:all,:select=>"login,user_id,count(user_id) as bookmark_count" ,:group=>"user_id" )
     @users_count = Bkmafolder.find(:all,:select=>"urllist_id,count(urllist_id) as users_count_num " ,:order=>"count(urllist_id) DESC",:group=>"urllist_id",:limit=>10)
     respond_to do |format|
       format.html # index.html.erb
       #format.xml  { render :xml => @bkmafolders }
       format.rss {
        render(:layout => false, :action => "index.rxml")
       }
     end
  end
  
  def show
     @bookmarklists = Bkmafolder.paginate(:all , :page => params[:page],:per_page => 10,:conditions=>["user_id=?",params[:id]],:order=>"created_at DESC")
     @users_count = Bkmafolder.find(:all,:select=>"urllist_id,count(urllist_id) as users_count_num " ,:group=>"urllist_id")
     @tags=Comment.find(:all,:select=>"comment,count(comment) as comment_count",:group=>"comment",:conditions=>["tag_flg=1 and user_id=?",params[:id]])
     @user_name = User.find(params[:id]).login
  end
  
end
