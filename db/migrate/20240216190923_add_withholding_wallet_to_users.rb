class AddWithholdingWalletToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :withholding_wallet, :string
  end
end
