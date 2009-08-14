class UrllistsController < ApplicationController
    #require 'digest/md5'
      require 'simple-json'
      
      before_filter :auth_filter ,:except=>:show
      def auth_filter
        redirect_to bkmafolders_path unless session[:login_no]
      end
      
  def show
     #@bookmarklists =Bkmafolder.paginate(:all,:page => params[:page],:per_page => 1,:conditions=>["urllist_id=?",params[:id]],:limit=>1)
     @bookmarklists =Urllist.find(:all,:conditions=>["id=?",params[:id]])
     @users_count = Bkmafolder.find(:all,:select=>"urllist_id,count(urllist_id) as users_count_num " ,:conditions=>["urllist_id=?",params[:id]],:group=>"urllist_id")
     @bookmark_users = Bkmafolder.find(:all,:conditions=>["urllist_id=?",params[:id]])
     @edit_delete_flg = @bookmark_users.any?{|bookmark_user|  bookmark_user.user_id==session[:login_no] }
     @create_user_name= User.find(@bookmarklists[0].create_user_id).login
     @update_user_name= User.find(@bookmarklists[0].update_user_id).login if @bookmarklists[0].update_user_id
    #respond_to do |format|
    #  format.html # show.html.erb
    #  format.xml  { render :xml => @urllist }
    #end
  end

  def new
    array=[]
    #1.Delete   "\"and"/" of end  
    #2.Decode
    arranged_url=URI.decode(params[:urllist][:url].gsub(/\/+$|\\+$/,""))
    
    #Trancefer "\"to"/" and attache the head "file:"  if top is "\\"
    if params[:urllist][:url].slice(0,2) == "\\\\"
      arranged_url="file:" + arranged_url.gsub(/[\\]/,"/")
    end
    
    # Check the URL that's already registed or not 
    @urllist=Urllist.find(:first,:conditions=>["url=?",arranged_url])
    
    unless @urllist  then
        @urllist = Urllist.new
        @urllist.url=arranged_url
        
        #Get tag array 
        my_tags=Comment.find(:all,:select=>"distinct comment",:conditions=>["tag_flg=1 and user_id=?",session[:login_no]])
        my_tags.each {|x| array << x[:comment] }
        @my_tags=array.to_json 
        @other_tags=""
        flash[:notice] = '新規に登録します。'
        
        respond_to do |format|
          format.html # new.html.erb
          format.xml  { render :xml => @urllist }
        end
    else
      
      # Branching which my bookmark exist or not.
      if Bkmafolder.find(:first,:conditions=>["urllist_id=? and user_id=?",@urllist.id,session[:login_no]]) then
          flash[:notice] = '自分のブックマークに既に登録済みです。下記から修正可能です。'
      else
          flash[:notice] = 'このブックマークは <b>' + @urllist.create_person_name + '</b> さんが既に登録済です。<br>自分のブックマークへ追加する時は下記に記入して更新ボタンを押してください。'
      end
      
      redirect_to(edit_urllist_path(@urllist.id))  
    end
      
      
  end


  def create
    
   begin
       #regist title
       @urllist = Urllist.new(params[:urllist])
       @urllist.create_user_id=session[:login_no]
       @urllist.save
       #analysis & regist tags&comments
       
       analysis_regist(params[:comment],@urllist.id)
       
       #regist bkmafolder
       Bkmafolder.create(:urllist_id=>@urllist.id,:user_id=>session[:login_no])
       
        respond_to do |format|
          flash[:notice] = '登録しました。' +'ok!!'
          format.html { redirect_to(urllist_path(@urllist.id)) }
          format.xml  { render :xml => @urllist, :status => :created, :location => @urllist }
        end
    rescue
        respond_to do |format|
          flash[:notice] = '登録に失敗しました。'+'booooo'
          format.html { render :action => "new" }
          format.xml  { render :xml => @urllist.errors, :status => :unprocessable_entity }
        end
    end
  end

  def update
    
     begin
         
         #delete all comments
         #Comment.delete_all("urllist_id=#{params[:id]} and user_id='#{session[:login_no]}'")
         Comment.delete_all(["urllist_id=? and user_id=?",params[:id],session[:login_no]])
         
         #urllist update
         @urllist = Urllist.find(params[:id])
         @urllist.update_attributes(:title=>params[:urllist][:title],:update_user_id=>session[:login_no])
         #regist on
         analysis_regist(params[:comment],params[:id])
         #Check data that be already registed or not 
         Bkmafolder.create(:urllist_id=>params[:id],:user_id=>session[:login_no]) if Bkmafolder.count(:all,:conditions=>["urllist_id=? and user_id=?" ,params[:id],session[:login_no]]) == 0
         
        flash[:notice] = '更新しました。' +'ok!!!'
        respond_to do |format|
          format.html { redirect_to(urllist_path(params[:id])) }
          format.xml  { head :ok }
        end

       redirect_to(edit_urllist_path)

      rescue
        flash[:notice] = '更新失敗しました。' + 'boooo!!'
      #  respond_to do |format|
      #    format.html { redirect_to(edit_urllist_path)}
      #    format.xml  { render :xml => @urllist.errors, :status => :unprocessable_entity }
      #  end
      end
    
  end

  def destroy
     Comment.delete_all(["urllist_id=?",params[:id]])
     Bkmafolder.delete_all(["user_id=? and urllist_id=?",session[:login_no],params[:id]])
     redirect_to(bkmafolder_path(session[:login_no]))
    #respond_to do |format|
    #  format.html { redirect_to(bkmafolder_path(session[:login_no])) }
    #  format.xml  { head :ok }
    #end
  end
  

  def edit
    builder = JsonBuilder.new
    array1=[]
    array2=[]
    array3=[]
    array4=[]
    
     
     @urllist = Urllist.find(:first,:conditions=>["urllists.id=?",params[:id]] ,:include=>:comment)
     
       for comment_row in @urllist.comment
          if session[:login_no] == comment_row.user_id then 
            if comment_row.tag_flg==1 then
              array1 << "[" + comment_row.comment + "]"
            else 
              array1 << comment_row.comment
            end
          end
       end
     
     
     @my_comments=array1.join(',').gsub(/\],/,"]")
     
     other_comment=Comment.find(:all,:select=>"distinct comment",:conditions=>["tag_flg=0 and user_id<>? and urllist_id=?",session[:login_no],params[:id]])
     for comment_row in other_comment
        array4 << comment_row[:comment]
     end
     @other_commments=array4.join(',')
     
     
     tags=Comment.find(:all,:select=>"distinct comment",:conditions=>["tag_flg=1 and user_id=? and urllist_id<>?",session[:login_no],params[:id]])
     tags.each {|x| array2 << x[:comment] }
     @my_tags=array2.to_json 
     
     othertags=Comment.find(:all,:select=>"distinct comment",:conditions=>["tag_flg=1 and urllist_id=? and user_id<>?",params[:id],session[:login_no]])
     othertags.each {|x| array3 << x[:comment] }
     @other_tags=array3.to_json 
    
  end
  
 
  def check
    @urllist = Urllist.new
  end

private
  def  analysis_regist(p_comment,p_urllist_id)
         return if p_comment ==""
          #タグ
            #空白タグは削除
            p_comment.gsub!(/\[\]/,"")
            #タグを配列化
            split_tags=p_comment.scan(/\[.*?\]/)
            #配列中のタグを除去
            split_tags.collect! {|x| x.slice(1,x.length-2)}
            #配列から重複した要素を取り除く
            split_tags.uniq!
            #[]をカンマに置き換える
            p_comment.gsub!(/\[.*?\]/,",")
           
          #コメント
            #重複するカンマを一つにまとめる
            p_comment.gsub!(/,+/,",")
            #文頭にカンマがあれば削除
            p_comment=~/^,?(.*)/
            #コメントで区切られているワードを配列へ
            split_comments = $1.split(",")
           
         #タグを登録する。
          for split_tag in split_tags
           @comments = Comment.new
           @comments.user_id=session[:login_no]
           @comments.comment=split_tag
           @comments.tag_flg=1
           @comments.urllist_id=p_urllist_id
           @comments.save
          end 
         
         #コメントを登録する。
          for split_comment in split_comments
           @comments = Comment.new           
           @comments.user_id=session[:login_no]
           @comments.comment=split_comment
           @comments.tag_flg=0
           @comments.urllist_id=p_urllist_id
           @comments.save
          end 
        
  end


end
