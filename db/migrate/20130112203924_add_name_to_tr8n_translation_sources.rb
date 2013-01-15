class AddNameToTr8nTranslationSources < ActiveRecord::Migration
  def self.up
    add_column :tr8n_translation_sources, :name, :string
    add_column :tr8n_translation_sources, :description, :text
  end

  def self.down
    remove_column :tr8n_translation_sources, :name
    remove_column :tr8n_translation_sources, :description
  end
end
