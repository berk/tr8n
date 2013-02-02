class AddStateToTr8nComponentTranslators < ActiveRecord::Migration
  def self.up
    add_column :tr8n_component_translators, :state, :string
  end

  def self.down
    remove_column :tr8n_component_translators, :state
  end
end
