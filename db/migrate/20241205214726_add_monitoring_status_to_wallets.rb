class AddMonitoringStatusToWallets < ActiveRecord::Migration[7.0]
  def change
    add_column :wallets, :monitoring_status, :boolean, default: false, null: false
  end
end
