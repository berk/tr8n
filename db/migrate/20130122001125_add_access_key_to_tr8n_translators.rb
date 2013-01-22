class AddAccessKeyToTr8nTranslators < ActiveRecord::Migration
  def self.up
    add_column :tr8n_translators, :access_key, :string
    add_index :tr8n_translators, [:access_key], :name => "tr8n_tran_key"
  end

  def self.down
    remove_column :tr8n_translators, :access_key
  end
end
