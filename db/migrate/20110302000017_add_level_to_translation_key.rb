class AddLevelToTranslationKey < ActiveRecord::Migration
  def self.up
    add_column :tr8n_translation_keys, :level, :integer, :default => 0
  end

  def self.down
    remove_column :tr8n_translation_keys, :level
  end
end
