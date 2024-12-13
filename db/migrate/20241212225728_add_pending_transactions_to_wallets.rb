class AddPendingTransactionsToWallets < ActiveRecord::Migration[7.0]
  def change
    if ActiveRecord::Base.connection.adapter_name.downcase.include?("sqlite")
      add_column :wallets, :pending_transactions, :json, default: [], null: false
    else
      add_column :wallets, :pending_transactions, :jsonb, default: [], null: false
    end
  end
end

