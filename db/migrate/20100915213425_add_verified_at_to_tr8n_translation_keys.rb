class AddVerifiedAtToTr8nTranslationKeys < ActiveRecord::Migration
  def self.up
    add_column :tr8n_translation_keys, :verified_at, :timestamp
  end

  def self.down
    remove_column :tr8n_translation_keys, :verified_at
  end
end
