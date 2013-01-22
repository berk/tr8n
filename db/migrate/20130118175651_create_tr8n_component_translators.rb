class CreateTr8nComponentTranslators < ActiveRecord::Migration
  def self.up
    create_table :tr8n_component_translators do |t|
      t.integer :component_id
      t.integer :translator_id
      t.timestamps
    end
    add_index :tr8n_component_translators, [:component_id], :name => "tr8n_comp_trn_comp_id"
    add_index :tr8n_component_translators, [:translator_id], :name => "tr8n_comp_trn_trn_id"
  end

  def self.down
    drop_table :tr8n_component_translators
  end
end
