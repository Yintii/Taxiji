class Wallet < ApplicationRecord
  belongs_to :user
  #make sure the primary key is a comination of wallet_address and chain
  self.primary_keys = :wallet_address, :chain
  validates :wallet_name, presence: true, length: { maximum: 50 }
  validates :wallet_address, presence: true, length: { maximum: 42 }
end

