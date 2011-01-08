class CreateTranslatorFollowing < ActiveRecord::Migration
  def self.up
    create_table :tr8n_translator_following do |t|
      t.integer     :translator_id
      t.integer     :object_id
      t.string      :object_type
      t.timestamps
    end
    
    add_index :tr8n_translator_following, [:translator_id]
  end

  def self.down
    drop_table :tr8n_translator_following
  end
end
