class CreateTr8nComponents < ActiveRecord::Migration
  def self.up
    create_table :tr8n_components do |t|
      t.integer :application_id
      t.string :name
      t.string :description
      t.timestamps
    end

    add_index :tr8n_components, [:application_id], :name => "tr8n_comp_app_id"
  end

  def self.down
    drop_table :tr8n_components
  end
end
