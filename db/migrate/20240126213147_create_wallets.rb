class CreateWallets < ActiveRecord::Migration[7.0]
  def change
    create_table :wallets do |t|
      t.string :wallet_name
      t.string :wallet_address

      t.timestamps
    end
  end
end
