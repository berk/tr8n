class AddExternalKeysToTr8nLanguages < ActiveRecord::Migration
  def self.up
    add_column :tr8n_languages, :google_key, :string
    add_column :tr8n_languages, :facebook_key, :string
  end

  def self.down
    remove_column :tr8n_languages, :google_key
    remove_column :tr8n_languages, :facebook_key
  end
end
