class AddPercentageAndChangePrimaryKeyToWallets < ActiveRecord::Migration[7.0]
  def change
    # Add the percentage column
    add_column :wallets, :percentage, :float

    # Remove the default primary key
    remove_column :wallets, :id
    remove_column :wallets, :wallet_address

    # Add the new primary key using wallet_address
    add_column :wallets, :wallet_address, :string, primary_key: true

    # Optionally, you can remove the existing wallet_address column if it's redundant
    # remove_column :wallets, :wallet_address

    # Ensure the new primary key is not null
    change_column_null :wallets, :wallet_address, false
  end
end
