class AddApplicationToLanguageCases < ActiveRecord::Migration
  def self.up
    add_column :tr8n_language_cases, :application, :string
  end

  def self.down
    remove_column :tr8n_language_cases, :application
  end
end
