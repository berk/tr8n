class CreateTr8nLanguageCaseRules < ActiveRecord::Migration
  
  def self.up
    create_table :tr8n_language_case_rules do |t|
      t.integer :language_case_id, :null => false
      t.integer :language_id
      t.integer :translator_id
      t.text    :definition, :null => false
      t.timestamps
    end
    add_index :tr8n_language_case_rules, [:language_case_id], :name => "tr8n_lcr_case_id"
    add_index :tr8n_language_case_rules, [:language_id], :name => "tr8n_lcr_lang_id"
    add_index :tr8n_language_case_rules, [:translator_id], :name => "tr8n_lcr_translator_id"
  end

  def self.down
    drop_table :tr8n_language_case_rules
  end
end
