class AddWalletAddressToWallets < ActiveRecord::Migration[7.0]
  def change
    add_column :wallets, :wallet_address, :string
  end
end
