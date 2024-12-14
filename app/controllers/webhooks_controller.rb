require 'eth'

class WebhooksController < ApplicationController
  before_action :authenticate_moralis_request
  skip_before_action :authenticate_user!, only: [:handle_transaction_data, :handle_created_stream]
  skip_before_action :verify_authenticity_token, only: [:handle_transaction_data, :handle_created_stream]

  def handle_transaction_data
    
    payload = JSON.parse(request.body.read)

    if payload["txs"][0]

      wallet_address = payload["txs"][0]["fromAddress"]
      value = payload["txs"][0]["value"]
      chain_id = payload["chainId"]

      wallet = find_wallet(wallet_address) 

      transaction = {
        "value": value,
        "chain_id": chain_id
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

end

