class AddUrlToTr8nTranslationSources < ActiveRecord::Migration
  def self.up
    add_column :tr8n_translation_sources, :url, :string
  end

  def self.down
    remove_column :tr8n_translation_sources, :url
  end
end
