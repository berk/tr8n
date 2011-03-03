class CreateTranslatorReports < ActiveRecord::Migration
  def self.up
    create_table :tr8n_translator_reports do |t|
      t.integer     :translator_id
      t.string      :state
      t.integer     :object_id
      t.string      :object_type
      t.string      :reason
      t.text        :comment
      t.timestamps
    end
    
    add_index :tr8n_translator_reports, [:translator_id]
  end

  def self.down
    drop_table :tr8n_translator_reports
  end
end
