class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users , :force => true do |t|
      t.string :identity_url
      t.string :login
      t.timestamps

    end

    add_column :bkmafolders, :user_id , :integer
    add_column :comments, :user_id , :integer
    add_column :urllists, :user_id , :integer
    add_column :urllists, :create_user_id ,:integer 
    add_column :urllists, :update_user_id ,:integer 
#    remove_column  :bkmafolders, :login 
#    remove_column  :comments, :login 
#    remove_column  :urllists, :login 
#    remove_column  :urllists,:create_person_name
#    remove_column  :urllists, :update_person_name
  end

  def self.down
    drop_table :users

    remove_column  :bkmafolders, :user_id 
    remove_column  :comments, :user_id 
    remove_column  :urllists, :user_id 
#    add_column  :bkmafolders, :login , :string
#    add_column  :comments, :login , :string 
#    add_column  :urllists, :login , :string
    
    remove_column  :urllists, :create_user_id 
    remove_column  :urllists, :update_user_id 
#    add_column  :urllists, :create_person_name ,:string
#    add_column  :urllists, :update_person_name ,:string
    
  end
end
