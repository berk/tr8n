class AddStateToTr8nComponentLanguages < ActiveRecord::Migration
  def self.up
    add_column :tr8n_component_languages, :state, :string
  end

  def self.down
    remove_column :tr8n_component_languages, :state
  end
end
