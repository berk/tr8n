class CreateTr8nSyncLogs < ActiveRecord::Migration
  def up
    create_table :tr8n_sync_logs do |t|
      t.timestamp :started_at
      t.timestamp :finshed_at
      t.integer   :translation_key_count
      t.integer   :translation_count
      t.timestamps
  end

  def down
    drop_table :tr8n_sync_logs
  end
end
