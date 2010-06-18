# Used for testing only
class CreateTestUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string  :name
      t.string  :mugshot
      t.boolean :admin
      t.boolean :guest
      t.string  :gender
      t.string  :link
      t.string  :locale
      
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
