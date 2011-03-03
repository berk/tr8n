class AddLevelToTr8nTranslator < ActiveRecord::Migration
  def self.up
    add_column :tr8n_translators, :level, :integer, :default => 0
  end

  def self.down
    remove_column :tr8n_translators, :level
  end
end
