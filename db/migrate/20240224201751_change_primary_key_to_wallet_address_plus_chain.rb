class ChangePrimaryKeyToWalletAddressPlusChain < ActiveRecord::Migration[7.0]
   def change
    # Add a new column to hold the combination of wallet_address and chain
    add_column :wallets, :composite_key, :string

    # Populate the new column with the combination of wallet_address and chain
    Wallet.all.each do |wallet|
      wallet.update(composite_key: "#{wallet.wallet_address.downcase}-#{wallet.chain.downcase}")
    end

    # Remove the existing primary key constraint
    remove_column :wallets, :wallet_address
    remove_column :wallets, :chain

    # Make the new column the primary key
    change_column :wallets, :composite_key, :string, primary_key: true
  end

  def down
    # Re-add the wallet_address column
    add_column :wallets, :wallet_address, :string
    add_column :wallets, :chain, :string

    # Split the composite_key to extract wallet_address and chain
    Wallet.all.each do |wallet|
      wallet.wallet_address, wallet.chain = wallet.composite_key.split('_')
      wallet.save
    end

    # Remove the composite_key column
    remove_column :wallets, :composite_key

    # Add back the primary key constraint on wallet_address
    change_column :wallets, :wallet_address, :string, primary_key: true
  end
end
