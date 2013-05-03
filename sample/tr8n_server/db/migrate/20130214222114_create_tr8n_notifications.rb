class CreateTr8nNotifications < ActiveRecord::Migration
  def self.up
    create_table :tr8n_notifications do |t|
      t.string      :type
      t.integer     :translator_id
      t.integer     :actor_id
      t.integer     :target_id
      t.string      :action
      t.string      :object_type
      t.integer     :object_id
      t.timestamp   :viewed_at
      t.timestamps
    end

    add_index :tr8n_notifications, :translator_id
    add_index :tr8n_notifications, [:object_type, :object_id]
  end

  def self.down
    drop_table :tr8n_notifications
  end
end
