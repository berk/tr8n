class CreateTr8nComponentSources < ActiveRecord::Migration
  def self.up
    create_table :tr8n_component_sources do |t|
      t.integer :component_id
      t.integer :translation_source_id
      t.timestamps
    end

    add_index :tr8n_component_sources, [:component_id]
    add_index :tr8n_component_sources, [:translation_source_id]
  end

  def self.down
    drop_table :tr8n_component_sources
  end
end
