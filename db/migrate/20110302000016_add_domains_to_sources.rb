class AddDomainsToSources < ActiveRecord::Migration
  def self.up
    add_column :tr8n_translation_sources, :translation_domain_id, :integer
  end

  def self.down
    remove_column :tr8n_translation_sources, :translation_domain_id
  end
end
