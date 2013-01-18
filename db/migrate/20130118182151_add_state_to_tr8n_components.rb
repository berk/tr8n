class AddStateToTr8nComponents < ActiveRecord::Migration
  def self.up
    add_column :tr8n_components, :state, :string
  end

  def self.down
    remove_column :tr8n_components, :state
  end
end
