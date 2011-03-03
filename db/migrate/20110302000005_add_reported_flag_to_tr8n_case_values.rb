class AddReportedFlagToTr8nCaseValues < ActiveRecord::Migration
  def self.up
    add_column :tr8n_language_case_value_maps, :reported, :boolean
  end

  def self.down
    remove_column :tr8n_language_case_value_maps, :reported
  end
end
