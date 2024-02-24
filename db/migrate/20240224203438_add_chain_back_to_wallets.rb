class AddChainBackToWallets < ActiveRecord::Migration[7.0]
  def change
    add_column :wallets, :chain, :string
  end
end
