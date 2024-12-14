class Wallet < ApplicationRecord
  belongs_to :user
  #make sure the primary key is a comination of wallet_address and chain
  self.primary_keys = :wallet_address, :chain
  validates :wallet_name, presence: true, length: { maximum: 50 }
  validates :wallet_address, presence: true, length: { maximum: 42 }
  validates :chain, presence: true
  validates :wallet_address, uniqueness: { scope: :chain, message: "Address and chain combination must be unique!" }

  #scopes
  scope :monitored, -> { where(monitoring_status: true) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  #custom methods
  def start_monitoring
    response = WalletMonitoringService.start(wallet_address: wallet_address)
    if response[:success]
      update!(monitoring_status: true)
      puts "Monitoring started for wallet #{wallet_address}: #{response[:data]}" 
      { success: true, message: "Monitoring started for wallet #{wallet_address}" }
    else
      Rails.logger.error("Failed to start monitoring service for wallet #{wallet_address}: #{response}")
      { failure: true, error: "Monitoring failed for #{wallet_address}" }
    end
  rescue StandardError => e
    Rails.logger.error("Error starting monitoring service for wallet #{wallet_address}: #{e.message}")
    false
  end


  def stop_monitoring
    WalletMonitoringService.stop(wallet_address: wallet_address).tap do |success|
      if success
        update!(monitoring_status: false)
      else
        Rails.logger.error("Failed to stop monitoring for wallet #{wallet_address}")
      end
    end
  rescue StandardError => e
    Rails.logger.error("Error with stopping monitoring service for wallet #{wallet_address}: #{e.message}")
    false
  end

  def update_pending_transactions(transaction)
    puts "Given transaction: #{transaction}"
    puts "Pending if it's here: #{pending_transactions}"
    current_transactions = pending_transactions ? pending_transactions : []
    puts "Current_transactions: #{current_transactions}"


    current_transactions << transaction

    update!(pending_transactions: current_transactions)

    puts "Updated pending transactions for wallet #{wallet_address}: #{transaction}"
  rescue StandardError => e
    Rails.logger.error("Error updating the pending transactions for #{wallet_address}: #{e.message}")
    false
  end

end

