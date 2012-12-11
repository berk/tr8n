class AddThresholdToLanguages < ActiveRecord::Migration
  def change
    add_column :tr8n_languages, :threshold, :integer, :default => 1
  end
end
