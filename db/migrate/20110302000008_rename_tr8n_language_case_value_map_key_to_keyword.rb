class RenameTr8nLanguageCaseValueMapKeyToKeyword < ActiveRecord::Migration
  def self.up
    rename_column :tr8n_language_case_value_maps, :key, :keyword
  end

  def self.down
    rename_column :tr8n_language_case_value_maps, :keyword, :key
  end
end
