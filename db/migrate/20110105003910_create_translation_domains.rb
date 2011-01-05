class CreateTranslationDomains < ActiveRecord::Migration
  def self.up
    create_table :tr8n_translation_domains do |t|
      t.string        :name
      t.string        :description
      t.integer       :source_count,  :default => 0
      t.timestamps
    end
    add_index :tr8n_translation_domains, [:name], :unique => true
  end

  def self.down
    drop_table :tr8n_translation_domains
  end
end
