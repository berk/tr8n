class CreateTr8nApplications < ActiveRecord::Migration
  def self.up
    create_table :tr8n_applications do |t|
      t.string :key
      t.string :name
      t.string :description
      t.timestamps
    end

    add_index :tr8n_applications, [:key]
  end

  def self.down
    drop_table :tr8n_applications
  end
end
