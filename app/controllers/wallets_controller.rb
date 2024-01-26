require('net/http')
require('uri')

class WalletsController < ApplicationController
  before_action :set_wallet, only: %i[ show edit update destroy ]

  # GET /wallets or /wallets.json
  def index
    @wallets = current_user.wallets
  end

  # GET /wallets/1 or /wallets/1.json
  def show
  end

  # GET /wallets/new
  def new
    @wallet = Wallet.new
  end

  # GET /wallets/1/edit
  def edit
  end

  # POST /wallets or /wallets.json
  def create
    @wallet = current_user.wallets.build(wallet_params)

    puts @wallet.inspect
    respond_to do |format|
      if @wallet.save
        send_data_to_another_server(@wallet)
        format.html { redirect_to wallet_url(@wallet), notice: "Wallet was successfully created." }
        format.json { render :show, status: :created, location: @wallet }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @wallet.errors, status: :unprocessable_entity }
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
    @wallet.destroy

    respond_to do |format|
      format.html { redirect_to wallets_url, notice: "Wallet was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wallet
      @wallet = Wallet.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def wallet_params
      puts params.inspect
      params.require(:wallet).permit(:wallet_name, :wallet_address)
    end
end


private


def send_data_to_another_server(wallet)
  # Use appropriate HTTP methods and libraries to send data
  # Example using Net::HTTP:
  uri = URI.parse('http://34.94.156.159:3000/api/wallet_submit')
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
  request.body = wallet.to_json
  puts request.body.inspect
  response = http.request(request)

  # Handle response as needed
  puts response.body if response.is_a?(Net::HTTPSuccess)
end
