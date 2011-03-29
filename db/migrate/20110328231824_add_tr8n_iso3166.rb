class AddTr8nIso3166 < ActiveRecord::Migration
  def self.up
    create_table :tr8n_iso_countries do |t|
      t.string  :code,                  :null => false
      t.string  :country_english_name,  :null => false
      t.timestamps
    end
    add_index :tr8n_iso_countries, [:code]

    create_table :tr8n_iso_countries_tr8n_languages, :id=>false do |t|
      t.integer :tr8n_iso_country_id
      t.integer :tr8n_language_id
    end
  end

  def self.down
  end
end
