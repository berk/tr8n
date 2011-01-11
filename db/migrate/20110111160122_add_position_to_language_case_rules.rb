class AddPositionToLanguageCaseRules < ActiveRecord::Migration
  def self.up
    add_column :tr8n_language_case_rules, :position, :integer
  end

  def self.down
    remove_column :tr8n_language_case_rules, :position
  end
end
