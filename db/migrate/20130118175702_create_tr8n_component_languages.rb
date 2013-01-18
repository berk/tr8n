class CreateTr8nComponentLanguages < ActiveRecord::Migration
  def self.up
    create_table :tr8n_component_languages do |t|
      t.integer :component_id
      t.integer :language_id
      t.timestamps
    end
    add_index :tr8n_component_languages, [:component_id]
    add_index :tr8n_component_languages, [:language_id]
  end

  def self.down
    drop_table :tr8n_component_languages
  end
end
