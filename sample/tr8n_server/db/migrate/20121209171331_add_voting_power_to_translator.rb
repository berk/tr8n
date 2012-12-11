class AddVotingPowerToTranslator < ActiveRecord::Migration
  def change
    add_column :tr8n_translators, :voting_power, :integer, :default => 1
  end
end
