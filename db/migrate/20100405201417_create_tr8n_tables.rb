class CreateTr8nTables < ActiveRecord::Migration
  def self.up
    create_table :tr8n_languages do |t|
      t.string  :locale,        :null => false
      t.string  :english_name,  :null => false
      t.string  :native_name
      t.boolean :enabled
      t.boolean :right_to_left
      t.integer :completeness
      t.integer :fallback_language_id
      t.text    :curse_words  
      t.integer :featured_index, :default => 0
      t.timestamps
    end
    add_index :tr8n_languages, [:locale]
    
    create_table :tr8n_language_rules do |t|
      t.integer :language_id, :null => false
      t.integer :translator_id
      t.string  :type
      t.text    :definition
      t.timestamps
    end
    add_index :tr8n_language_rules, [:language_id]
    add_index :tr8n_language_rules, [:language_id, :translator_id]
    
    create_table :tr8n_language_users do |t|
      t.integer :language_id,   :null => false
      t.integer :user_id,       :null => false
      t.integer :translator_id
      t.boolean :manager,       :default => false
      t.timestamps
    end
    add_index :tr8n_language_users, [:user_id]
    add_index :tr8n_language_users, [:language_id, :user_id]
    add_index :tr8n_language_users, [:language_id, :translator_id]
    add_index :tr8n_language_users, [:created_at]
    add_index :tr8n_language_users, [:updated_at]
    
    create_table :tr8n_language_metrics do |t|
      t.string  :type
      t.integer :language_id,           :null => false
      t.date    :metric_date
      t.integer :user_count,            :default => 0
      t.integer :translator_count,      :default => 0
      t.integer :translation_count,     :default => 0
      t.integer :key_count,             :default => 0
      t.integer :locked_key_count,      :default => 0
      t.integer :translated_key_count,  :default => 0
      
      t.timestamps
    end
    add_index :tr8n_language_metrics, [:language_id]
    add_index :tr8n_language_metrics, [:created_at]
    
    create_table :tr8n_translators do |t|
      t.integer :user_id,     :null => false
      t.boolean :inline_mode, :default => false
      t.boolean :blocked,     :default => false
      t.integer :fallback_language_id
      t.integer :rank,        :default => 0 
      t.timestamps
    end
    add_index :tr8n_translators, [:user_id]
    add_index :tr8n_translators, [:created_at]

    create_table :tr8n_translator_logs do |t|
      t.integer :translator_id
      t.integer :user_id,       :limit => 8
      t.string  :action
      t.integer :action_level
      t.string  :reason
      t.string  :reference
      t.timestamps
    end
    add_index :tr8n_translator_logs, [:translator_id]
    add_index :tr8n_translator_logs, [:user_id]
    add_index :tr8n_translator_logs, [:created_at]
    
    create_table :tr8n_translator_metrics do |t|
      t.integer :translator_id,         :null => false
      t.integer :language_id,           :limit => 8
      t.integer :total_translations,    :default => 0
      t.integer :total_votes,           :default => 0
      t.integer :positive_votes,        :default => 0
      t.integer :negative_votes,        :default => 0
      t.integer :accepted_translations, :default => 0
      t.integer :rejected_translations, :default => 0
      t.timestamps
    end
    add_index :tr8n_translator_metrics, [:translator_id]
    add_index :tr8n_translator_metrics, [:translator_id, :language_id]
    add_index :tr8n_translator_metrics, [:created_at]
    
    create_table :tr8n_translation_keys do |t|
      t.string  :key,   :null => false
      t.text    :label, :null => false
      t.text    :description
      t.timestamps
    end
    add_index :tr8n_translation_keys, [:key]

    create_table :tr8n_translation_sources do |t|
      t.string  :source
      t.timestamps
    end
    add_index :tr8n_translation_sources, [:source]

    create_table :tr8n_translation_key_sources do |t|
      t.integer :translation_key_id, :null => false
      t.integer :translation_source_id, :null => false
      t.text    :details
      t.timestamps
    end
    add_index :tr8n_translation_key_sources, [:translation_key_id]
    add_index :tr8n_translation_key_sources, [:translation_source_id]

    create_table :tr8n_translation_key_locks do |t|
      t.integer :translation_key_id, :null => false
      t.integer :language_id, :null => false
      t.integer :translator_id
      t.boolean :locked, :default => false
      t.timestamps
    end
    add_index :tr8n_translation_key_locks, [:translation_key_id, :language_id]

    create_table :tr8n_translations do |t|
      t.integer :translation_key_id,  :null => false
      t.integer :language_id,         :null => false
      t.integer :translator_id,       :null => false
      t.text    :label,               :null => false
      t.integer :rank,                :default => 0
      t.integer :approved_by_id,      :limit => 8
      t.text    :rules      
      t.timestamps
    end
    add_index :tr8n_translations, [:translator_id]
    add_index :tr8n_translations, [:translation_key_id, :translator_id, :language_id]
    add_index :tr8n_translations, [:created_at]
  
    create_table :tr8n_translation_votes do |t|
      t.integer :translation_id,      :null => false
      t.integer :translator_id,       :null => false
      t.integer :vote,                :null => false
      t.timestamps
    end
    add_index :tr8n_translation_votes, [:translator_id]
    add_index :tr8n_translation_votes, [:translation_id, :translator_id]

    create_table :tr8n_glossary do |t|
      t.string  :keyword
      t.text    :description
      t.timestamps
    end
    add_index :tr8n_glossary, [:keyword]
    
    create_table :tr8n_language_forum_topics do |t|
      t.integer :translator_id, :null => false
      t.integer :language_id
      t.text    :topic, :null => false
      t.timestamps
    end
    add_index :tr8n_language_forum_topics, [:language_id]
    add_index :tr8n_language_forum_topics, [:translator_id]
    
    create_table :tr8n_language_forum_messages do |t|
      t.integer :language_id, :null => false
      t.integer :language_forum_topic_id, :null => false
      t.integer :translator_id, :null => false
      t.text    :message, :null => false
      t.timestamps
    end
    add_index :tr8n_language_forum_messages, [:language_id]
    add_index :tr8n_language_forum_messages, [:translator_id]
    add_index :tr8n_language_forum_messages, [:language_id, :language_forum_topic_id]
    
    create_table :tr8n_language_forum_abuse_reports do |t|
      t.integer :language_id, :null => false
      t.integer :translator_id, :null => false
      t.integer :language_forum_message_id, :null => false
      t.string  :reason
      t.timestamps
    end
    add_index :tr8n_language_forum_abuse_reports, [:language_id]
    add_index :tr8n_language_forum_abuse_reports, [:language_id, :translator_id]
    add_index :tr8n_language_forum_abuse_reports, [:language_forum_message_id]
  end

  def self.down
    drop_table :tr8n_languages
    drop_table :tr8n_language_rules
    drop_table :tr8n_language_users
    drop_table :tr8n_language_metrics
    drop_table :tr8n_translators
    drop_table :tr8n_translator_logs
    drop_table :tr8n_translator_metrics
    drop_table :tr8n_translation_keys
    drop_table :tr8n_translation_sources
    drop_table :tr8n_translation_key_sources
    drop_table :tr8n_translation_key_locks
    drop_table :tr8n_translations
    drop_table :tr8n_translation_rules
    drop_table :tr8n_translation_votes
    drop_table :tr8n_glossary
    drop_table :tr8n_language_forum_messages
    drop_table :tr8n_language_forum_topics
    drop_table :tr8n_language_forum_abuse_reports
  end
end