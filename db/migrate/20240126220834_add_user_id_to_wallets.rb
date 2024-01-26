class AddUserIdToWallets < ActiveRecord::Migration[7.0]
  def change
    add_reference :wallets, :user, null: false, foreign_key: true
  end
end
