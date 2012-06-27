class AddRemoteIdToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :remote_id, :integer
    add_index :users, [:remote_id]
  end
end
