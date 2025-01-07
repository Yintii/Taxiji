require 'net/http'
require 'json'
require 'uri'

class WalletMonitoringService

  #Render did not like this when I tried to deploy
  #so we've commenting it out and put the Rails const in its place

  #API_KEY = Rails.application.credentials.moralis[:api_key]

  def self.start(wallet_address)

    puts "Checking for stream id"
    stream_id = check_for_existing_stream
    puts "stream id: #{stream_id}"
    wallet_added_to_stream = add_wallet_to_stream(stream_id, wallet_address)
    {success: true, message: "Started"}

  end

  def self.stop(wallet_address)

    stream_id = check_for_existing_stream
    response = delete_address_from_stream(stream_id, wallet_address)
    puts "Wallet stop response: #{response}"
    { success: true, message: "Stop wallet faux function" }

  end

  def self.check_for_existing_stream
    begin 
      puts "Checking we can read the api key..."
      puts Rails.application.credentials.moralis[:api_key]

      uri = URI.parse('https://api.moralis-streams.com/streams/evm?limit=1')
      headers = {
        'accept' => 'application/json',
        'X-API-Key' => Rails.application.credentials.moralis[:api_key]
      }
      response_body = get_response_body_GET(uri, headers)
      puts "Checking for existing stream service function"
      puts "Response Body: #{response_body}"
      total_streams = response_body.dig('total')
      puts "Total streams: #{total_streams}"
    rescue SocketError => e
      puts "Network error #{e.message}"
    rescue => e
      puts "An error occurred: #{e.message}"
    end


   if total_streams > 0
      puts "We have streams to choose from"
      response_body.dig('result')[0]['id']
    else
      puts "No streasms"
      stream_id = create_new_stream
    end
  end

  def self.create_new_stream

    puts "We need to create a new stream!"
    uri = URI.parse('https://api.moralis-streams.com/streams/evm')
    headers = {
      'accept' => 'application/json',
      'X-API-Key' => Rails.application.credentials.moralis[:api_key],
      'content-type' => 'application/json'
    }

    base_url = Rails.env.production? ? ENV['LIVE_URL'] : ENV['LOCAL_URL']
    webhook_url = "https://" +  base_url + ENV['WEBHOOK_PATH']
    puts "Webhook url: #{webhook_url}"

    payload = {
      webhookUrl: webhook_url,
      description: 'new-transaction-stream',
      tag: 'taxolotl',
      chainIds: ['0xaa36a7'],
      includeContractLogs: true,
      includeNativeTxs: true,
      includeInternalTxs: true
    }.to_json
  
    response_body = get_response_body_PUT(uri, payload, headers)
    puts "Response body from create_new_stream: #{response_body}"

    return response_body.dig('id')
  rescue StandardError => e
    Rails.logger.error("There is an issue with starting the monitoring function: #{e.message}")
    false
  end

  def self.add_wallet_to_stream(stream_id, wallet_address)
 
      address = wallet_address[:wallet_address]

      uri = URI.parse("https://api.moralis-streams.com/streams/evm/#{stream_id}/address")
  
      headers = {
        'accept' => 'application/json',
        'X-API-Key' => Rails.application.credentials.moralis[:api_key],
        'content-type' => 'application/json'
      }
      
      payload = {
        address: address
      }.to_json
   
      response_body = get_response_body_POST(uri, payload, headers)

    rescue StandardError => e
      Rails.logger.error("Error adding address to stream: #{e.message}")
      nil
  end

  def self.delete_address_from_stream(stream_id, wallet_address)
    
    address = wallet_address[:wallet_address]

    uri = URI.parse("https://api.moralis-streams.com/streams/evm/#{stream_id}/address")

    headers = {
      'accept' => 'application/json',
      'X-API-Key' => Rails.application.credentials.moralis[:api_key],
      'content-type' => 'application/json'
    }

    payload = {
      address: address
    }.to_json

    response_body = get_response_body_DELETE(uri, payload, headers)

    puts "Delete response body: #{response_body}"

  end

  def self.get_response_body_POST(uri, payload, headers)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path, headers)
    request.body = payload
    response = http.request(request)
    return JSON.parse(response.body)
  end

  def self.get_response_body_GET(uri, headers)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri, headers)
    response = http.request(request)
    return JSON.parse(response.body)
  end

  def self.get_response_body_PUT(uri, payload, headers)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Put.new(uri, headers)
    request.body = payload
    response = http.request(request)
    return JSON.parse(response.body)
  end

  def self.get_response_body_DELETE(uri, payload, headers)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Delete.new(uri, headers)
    request.body = payload
    response = http.request(request)
    return JSON.parse(response.body)
  end

end

