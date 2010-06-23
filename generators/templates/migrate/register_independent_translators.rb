# if your site does not have users, but you would still like to use tr8n
# or if you want to register independent, not linked translators

class RegisterIndependentTranslators < ActiveRecord::Migration
  def self.up
    add_column :tr8n_translators, :name, :string
    add_column :tr8n_translators, :email, :string
    add_column :tr8n_translators, :password, :string
    add_column :tr8n_translators, :admin, :boolean
    add_column :tr8n_translators, :mugshot, :string
    add_column :tr8n_translators, :link, :string
    add_column :tr8n_translators, :locale, :string
    
    add_index :tr8n_translators, [:email]
    add_index :tr8n_translators, [:email, :password]
  end

  def self.down
    remove_column :tr8n_translators, :name
    remove_column :tr8n_translators, :email
    remove_column :tr8n_translators, :password
    remove_column :tr8n_translators, :admin
    remove_column :tr8n_translators, :mugshot
    remove_column :tr8n_translators, :link
    remove_column :tr8n_translators, :locale
  end
end

