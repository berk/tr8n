class AddAdminFlagToTranslationKeys < ActiveRecord::Migration
  def self.up
    add_column :tr8n_translation_keys, :admin, :boolean
  end

  def self.down
    remove_column :tr8n_translation_keys, :admin
  end
end
