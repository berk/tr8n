class AddCompletenessToT8nTranslationSources < ActiveRecord::Migration
  def self.up
    add_column :tr8n_translation_sources, :completeness, :integer, :default => 0
  end

  def self.down
    remove_column :tr8n_translation_sources, :completeness
  end
end
