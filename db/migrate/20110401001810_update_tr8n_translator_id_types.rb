class UpdateTr8nTranslatorIdTypes < ActiveRecord::Migration
  def self.up
    change_column :tr8n_language_case_rules, :translator_id, :integer, :limit => 8
    change_column :tr8n_language_case_value_maps, :translator_id, :integer, :limit => 8
    change_column :tr8n_language_cases, :translator_id, :integer, :limit => 8
    change_column :tr8n_translation_key_comments, :translator_id, :integer, :limit => 8, :null => false
    change_column :tr8n_translation_key_comments, :translator_id, :integer, :limit => 8
    change_column :tr8n_translator_following, :translator_id, :integer, :limit => 8
    change_column :tr8n_translator_reports, :translator_id, :integer, :limit => 8
  end

  def self.down
    change_column :tr8n_language_case_rules, :translator_id, :integer
    change_column :tr8n_language_case_value_maps, :translator_id, :integer
    change_column :tr8n_language_cases, :translator_id, :integer
    change_column :tr8n_translation_key_comments, :translator_id, :integer, :null => false
    change_column :tr8n_translation_key_comments, :translator_id, :integer
    change_column :tr8n_translator_following, :translator_id, :integer
    change_column :tr8n_translator_reports, :translator_id, :integer
  end
end
