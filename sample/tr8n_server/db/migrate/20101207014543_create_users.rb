class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email
      t.string :password
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.string :mugshot
      t.string :locale
      t.string :link
      
      t.timestamps
    end
    
    add_index :users, [:email]
    add_index :users, [:email, :password]    
  end

  def self.down
    drop_table :users
  end
end
