class MakePasswordsSecure < ActiveRecord::Migration
  def self.up
  	remove_column :users, :password
    add_column :users, :crypted_password, :string, :default => nil
    add_column :users, :salt, :string, :default => nil
  end

  def self.down
  	add_column :users, :password, :string
    remove_column :users, :crypted_password
    remove_column :users, :salt
  end
end
