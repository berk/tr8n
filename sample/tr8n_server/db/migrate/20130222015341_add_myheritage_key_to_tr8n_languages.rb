class AddMyheritageKeyToTr8nLanguages < ActiveRecord::Migration
  def self.up
    add_column :tr8n_languages, :myheritage_key, :string
  end

  def self.down
    remove_column :tr8n_languages, :myheritage_key, :string
  end
end
