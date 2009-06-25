class CreateBkmafolders < ActiveRecord::Migration
  def self.up
    create_table :bkmafolders do |t|
      t.integer :urllist_id
      t.string :login
      t.timestamps
    end
  end

  def self.down
    drop_table :bkmafolders
  end
end
