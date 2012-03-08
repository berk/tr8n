class CreateTr8nTranslationKeyComments < ActiveRecord::Migration
  def self.up
    create_table :tr8n_translation_key_comments do |t|
      t.integer :language_id, :null => false
      t.integer :translation_key_id, :null => false
      t.integer :translator_id, :null => false
      t.text    :message, :null => false
      t.timestamps
    end
    add_index :tr8n_translation_key_comments, [:language_id], :name => "tr8n_tkey_msgs_lang_id"
    add_index :tr8n_translation_key_comments, [:translator_id], :name => "tr8n_tkey_msgs_translator_id"
    add_index :tr8n_translation_key_comments, [:language_id, :translation_key_id], :name => "tr8n_tkey_msgs_lang_id_tkey_id"
  end

  def self.down
    drop_table :tr8n_translation_key_comments
  end
end
