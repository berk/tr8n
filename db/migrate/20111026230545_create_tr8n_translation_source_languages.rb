class CreateTr8nTranslationSourceLanguages < ActiveRecord::Migration
  def change
    create_table :tr8n_translation_source_languages do |t|
      t.integer   :language_id
      t.integer   :translation_source_id
      t.timestamps
    end
    
    add_index :tr8n_translation_source_languages, [:language_id, :translation_source_id], :name => :tsllt
  end
end