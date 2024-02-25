class ChangeWalletsPrimaryKeyToComposite < ActiveRecord::Migration[7.0]
  def change
    # Remove the existing primary key
    remove_column :wallets, :wallet_address

    # Add the new primary key using wallet_address
    add_column :wallets, :wallet_address, :string

    #make the primary key a combination of wallet_address and chain
    add_index :wallets, [:wallet_address, :chain], unique: true
    
  end
end
