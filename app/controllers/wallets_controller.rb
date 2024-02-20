require('net/http')
require('uri')

class WalletsController < ApplicationController
  before_action :set_wallet, only: %i[ show edit update destroy ]

  # GET /wallets or /wallets.json
  def index
    @wallets = current_user.wallets
    get_pending_transactions(current_user)
    #create a hash of the transactions, with the chain as the key
    @pending_transactions_hash = Hash.new
    @pending_transactions.each do |transaction|
      if @pending_transactions_hash[transaction['chain']].nil?
        @pending_transactions_hash[transaction['chain']] = Array.new
      end
      @pending_transactions_hash[transaction['chain']].push(transaction)
    end
    puts "Pending Transactions Hash: " + @pending_transactions_hash.inspect
  end

  # GET /wallets/1 or /wallets/1.json
  def show
    get_pending_transactions(current_user)
  end

  # GET /wallets/new
  def new
    @wallet = Wallet.new
    @user = current_user;
  end

  # GET /wallets/1/edit
  def edit
  end

  # POST /wallets or /wallets.json
  def create
    @wallet = current_user.wallets.build(wallet_params)

    if @wallet.chain == 'Withholding Wallet'
      current_user.withholding_wallet = @wallet.wallet_address
      if current_user.save
        respond_to do |format|
          #redirect to the new wallet
          format.html { redirect_to wallet_url(@wallet), notice: "Wallet was successfully created." }
          format.json { render :show, status: :created, location: @wallet }
        end
      else
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @wallet.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        if @wallet.save
          send_data_to_track_wallet(@wallet, current_user.withholding_wallet)

          format.html { redirect_to wallet_url(@wallet), notice: "Wallet was successfully created." }
          format.json { render :show, status: :created, location: @wallet }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @wallet.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /wallets/1 or /wallets/1.json
  def update
    respond_to do |format|
      if @wallet.update(wallet_params)
        format.html { redirect_to wallet_url(@wallet), notice: "Wallet was successfully updated." }
        format.json { render :show, status: :ok, location: @wallet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @wallet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wallets/1 or /wallets/1.json
  def destroy

    #if withholding wallet, remove from user
    if @wallet.wallet_address == current_user.withholding_wallet
      current_user.withholding_wallet = nil
      current_user.save
    end


    @wallet.destroy

    send_data_to_stop_tracking_wallet(@wallet)

    respond_to do |format|
      format.html { redirect_to wallets_url, notice: "Wallet was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wallet
      @wallet = Wallet.find(params[:id]) rescue nil
    end

    # Only allow a list of trusted parameters through.
    def wallet_params
      puts params.inspect
      params.require(:wallet).permit(:wallet_name, :wallet_address, :chain)
    end
end


private


def send_data_to_track_wallet(wallet_to_monitor, withholding_wallet)
  # Use appropriate HTTP methods and libraries to send data
  # Example using Net::HTTP:
  uri = URI.parse('https://server.taxolotl.xyz/api/wallet_submit')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
  request.body = { wallet: wallet_to_monitor, withholding_wallet: withholding_wallet }.to_json
  puts request.body.inspect
  response = http.request(request)

  # Handle response as needed
  puts response.body
end

def send_data_to_stop_tracking_wallet(wallet)
  # Use appropriate HTTP methods and libraries to send data
  # Example using Net::HTTP:
  uri = URI.parse('https://server.taxolotl.xyz/api/wallet_stop')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
  request.body = wallet.to_json
  puts request.body.inspect
  response = http.request(request)

  # Handle response as needed
  puts response.body
end

def get_pending_transactions(current_user)
    @user_id = current_user.id
    @user_withholding_wallet = current_user.withholding_wallet
    uri = URI.parse("https://server.taxolotl.xyz/api/pending_transactions/#{@user_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    http.use_ssl = true
    response = http.request(request)
    @pending_transactions = JSON.parse(response.body)

    puts "Pending Transactions: " + @pending_transactions.inspect
end
