class CreateTr8nTranslationSourceMetrics < ActiveRecord::Migration
  def self.up
    create_table :tr8n_translation_source_metrics do |t|
      t.integer :translation_source_id, :null => false
      t.integer :language_id,           :null => false
      t.integer :key_count,             :default => 0
      t.integer :locked_key_count,      :default => 0
      t.integer :translation_count,     :default => 0      
      t.integer :translated_key_count,  :default => 0
      t.timestamps
    end
    add_index :tr8n_translation_source_metrics, [:translation_source_id, :language_id]
  end

  def self.down
    drop_table :tr8n_translation_source_metrics
  end
end
