class CreateTr8nSyncTables < ActiveRecord::Migration
  def up
    create_table :tr8n_sync_logs do |t|
      t.timestamp :started_at
      t.timestamp :finished_at
      t.integer   :keys_sent
      t.integer   :translations_sent
      t.integer   :keys_received
      t.integer   :translations_received
      t.timestamps
    end
    
    add_column :tr8n_translation_keys, :synced_at, :timestamp
    add_column :tr8n_translations, :synced_at, :timestamp
  end

  def down
    drop_table :tr8n_sync_logs
    remove_column :tr8n_translation_keys, :synced_at
    remove_column :tr8n_translations, :synced_at
  end
end
