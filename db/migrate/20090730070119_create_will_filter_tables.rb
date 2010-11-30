class CreateWillFilterTables < ActiveRecord::Migration
  def self.up
    create_table :wf_filters do |t|
      t.string      :type
      t.string      :name
      t.text        :data
      t.integer     :user_id
      t.string      :model_class_name
      
      t.timestamps
    end
    
    add_index :wf_filters, [:user_id]
  end
  
  def self.down
    drop_table :wf_filters
  end
end
