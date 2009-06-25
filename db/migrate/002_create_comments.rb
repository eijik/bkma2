class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :urllist_id
      t.string :login
      t.text :comment
      t.integer :tag_flg
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
