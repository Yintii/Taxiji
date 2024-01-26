class Wallet < ApplicationRecord
  validates :wallet_name, presence: true, length: { maximum: 50 }
  validates :wallet_address, presence: true, length: { maximum: 42 }
end

