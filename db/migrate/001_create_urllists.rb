class CreateUrllists < ActiveRecord::Migration
  def self.up
    create_table :urllists do |t|
      t.text :url
      t.string :title
      t.timestamps
      t.string  :create_person_name
      t.string  :update_person_name
    end
  end

  def self.down
    drop_table :urllists
  end
end
