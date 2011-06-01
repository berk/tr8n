class AddTypeToTr8nTranslationKeys < ActiveRecord::Migration
  def self.up
    add_column :tr8n_translation_keys, :type, :string
  end

  def self.down
    remove_column :tr8n_translation_keys, :type, :string
  end
end
