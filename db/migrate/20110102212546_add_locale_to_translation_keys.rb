class AddLocaleToTranslationKeys < ActiveRecord::Migration
  def self.up
    add_column :tr8n_translation_keys, :locale, :string
  end

  def self.down
    remove_column :tr8n_translation_keys, :locale
  end
end
