class AddKeyToTr8nComponents < ActiveRecord::Migration
  def self.up 
    add_column :tr8n_components, :key, :string
    add_index :tr8n_components, [:key], :name => "tr8n_comp_key"
  end

  def self.down
    remove_column :tr8n_components, :key
  end
end
