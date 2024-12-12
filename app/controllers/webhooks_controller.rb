require 'eth'

class WebhooksController < ApplicationController
  before_action :authenticate_moralis_request
  skip_before_action :authenticate_user!, only: [:handle_transaction_data, :handle_created_stream]
  skip_before_action :verify_authenticity_token, only: [:handle_transaction_data, :handle_created_stream]

  def handle_transaction_data
    
    payload = JSON.parse(request.body.read)

    Rails.logger.debug "Recieved a TRANSACTION payload: #{payload}"

    render json: { message: 'Success' }, status: :ok
  rescue JSON::ParseError
    render json: { error: 'Invalid JSON payload: handle_transaction_data'}, status: :unprocessable_entity
  end

  def handle_created_stream
    payload = JSON.parse(request.body.read)
    Rails.logger.debug "Recieved a CREATED STREAM payload: #{payload}"
    render json: { message: 'Success' }, status: :ok
  rescue JSON::ParseError
    render json: { error: 'Invalid JSON payload: handle_created_stream'}, status: :unprocessable_entity
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
end

