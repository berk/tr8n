class CreateIpLocations < ActiveRecord::Migration
  def self.up
    create_table :tr8n_ip_locations do |t|
      t.integer   :low,       :limit => 8
      t.integer   :high,      :limit => 8
      t.string    :registry,  :limit => 20
      t.date      :assigned
      t.string    :ctry,      :limit => 2
      t.string    :cntry,     :limit => 3
      t.string    :country,   :limit => 80
      t.timestamps
    end

    add_index :tr8n_ip_locations, [:low]
    add_index :tr8n_ip_locations, [:high]
  end

  def self.down
    drop_table :tr8n_ip_locations
  end
end
