class AddRemoteIdToTr8nTranslators < ActiveRecord::Migration
  def change
    add_column :tr8n_translators, :remote_id, :integer
  end
end
