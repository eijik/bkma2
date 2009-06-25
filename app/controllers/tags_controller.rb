class TagsController < ApplicationController
  def index 
     @tags=Comment.find(:all,:select=>"comment,count(comment) as comment_count",:order=>"comment_count DESC",:group=>"comment",:conditions=>["tag_flg=1"],:limit=>100)
     render :layout=>false
  end
  
  def show
     @bookmarklists = Comment.paginate(:all,:page => params[:page],:per_page => 10,:select=>"urllist_id",:order=>"urllist_id",:conditions=>["comment=?",URI.decode(params[:id])],:group=>"urllist_id")
     #@bookmarklists = Comment.find(:all,:select=>"urllist_id,created_at",:order=>"urllist_id",:conditions=>["comment=?",URI.decode(params[:id])],:group=>"urllist_id")
     
     @users_count = Bkmafolder.find(:all,:select=>"urllist_id,count(urllist_id) as users_count_num " ,:group=>"urllist_id")
  end
end
