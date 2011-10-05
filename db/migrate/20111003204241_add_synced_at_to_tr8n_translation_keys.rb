class AddSyncedAtToTr8nTranslationKeys < ActiveRecord::Migration
  def change
    add_column :tr8n_translation_keys, :synced_at, :timestamp
  end
end
