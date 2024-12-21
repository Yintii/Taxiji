require 'eth'

class WebhooksController < ApplicationController
  before_action :authenticate_moralis_request
  skip_before_action :authenticate_user!, only: [:handle_transaction_data, :handle_created_stream]
  skip_before_action :verify_authenticity_token, only: [:handle_transaction_data, :handle_created_stream]

  def handle_processed_transaction
    
    payload = JSON.parse(request.body.read)



  end

  def handle_transaction_data
    
    payload = JSON.parse(request.body.read)

    contract_address = "0x7509aa80ef5a70f0e8ec15018916574097dd1137".downcase

    if payload["txs"][0] and payload['confirmed'] == false and payload["txs"][0]["toAddress"] != contract_address

      wallet_address = payload["txs"][0]["fromAddress"]
      value = payload["txs"][0]["value"]
      chain_id = payload["chainId"]
      hash = payload.dig('block')['hash']

      wallet = find_wallet(wallet_address) 

      puts "OUR WALLET : #{wallet.inspect}"

      puts "transaction HASH: #{hash}"

      withholding_wallet = get_withholding_wallet(wallet.user_id)

      puts "GOT THE WITHHOLDING WALLET: #{withholding_wallet}"

      transaction = {
        "value": value,
        "chain_id": chain_id,
        "user_id": wallet.user_id,
        "transaction_hash": hash,
        "withholding_wallet": withholding_wallet
      }

      
      wallet.update_pending_transactions(transaction)

      if wallet.save
        puts "saved transactions successfully"
      else
        puts "sucks to suck"
      end
    else
      Rails.logger.debug "Not a transaction payload..."
    end

    render json: { message: 'Success' }, status: :ok
  rescue JSON::ParserError
    render json: { error: 'Invalid JSON payload: handle_transaction_data'}, status: :unprocessable_entity
  end

  private

  def authenticate_moralis_request
    # Assuming Moralis sends a secret token in headers for authentication

    puts "Authenticate moralis request origin: #{request.host}"

    if request.host == "localhost"
      return {success: true, "message": 'request from localhost' }
    elsif request.host == "taxolotl.xyz"
      return {success: true, "message": "request from taxolotl.xyz" }
    end

    provided_signature = request.headers['x-signature']
    raise 'Signature not provided' unless provided_signature

    body = request.body.read
    secret = Rails.application.credentials.moralis[:webhook_secret]

    expected_signature = Eth::Util.keccak256(body + secret).unpack1('H*')
    expected_signature = "0x#{expected_signature}" if provided_signature.start_with?('0x')

    unless ActiveSupport::SecurityUtils.secure_compare(provided_signature, expected_signature)
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def find_wallet(wallet_address)
    wallet = Wallet.find_by('LOWER(wallet_address) = ?', wallet_address)
  end

  def get_withholding_wallet(user_id)
    user = User.find_by(id: user_id)
    withholding_wallet = user.withholding_wallet
  end

end

