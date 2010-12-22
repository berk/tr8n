class AddTranslationCountToKeys < ActiveRecord::Migration
  def self.up
    add_column :tr8n_translation_keys, :translation_count, :integer
  end

  def self.down
    remove_column :tr8n_translation_keys, :translation_count
  end
end
