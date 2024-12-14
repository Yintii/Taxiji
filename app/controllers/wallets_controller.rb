require('net/http')
require('uri')

class WalletsController < ApplicationController
  before_action :set_wallet, only: %i[ show edit update destroy ]

  # GET /wallets or /wallets.json
  def index
    @wallets = current_user.wallets
    @user = current_user

    @pending_transactions = @wallets.map do |wallet|
      {
        wallet_address: wallet[:wallet_address],
        pending_transactions: wallet[:pending_transactions]
      }
    end

    if @pending_transactions.empty?
      @pending_transactions = nil
    end

    puts "Pending Transactions Hash: " + @pending_transactions.inspect
  end

  # GET /wallets/1 or /wallets/1.json
  def show
    #get_pending_transactions(current_user)
    @wallet = Wallet.find(params[:id])
    @pending_transactions = @wallet.pending_transactions
    puts "Wallet: #{@wallet.inspect}"
    puts "pending transactions: #{@pending_transactions.inspect}"
  end

  # GET /wallets/new
  def new
    @wallet = Wallet.new
    @user = current_user
  end

  # GET /wallets/1/edit
  def edit
  end

  # POST /wallets or /wallets.json
  def create
    @wallet = current_user.wallets.build(wallet_params)

    puts "Wallet to create: #{@wallet.inspect}"

    if @wallet.chain == 'Withholding'
      current_user.withholding_wallet = @wallet.wallet_address
      if current_user.save
        respond_to do |format|
          
          #we do not need to create a monitoring service for the witholding wallets  
          #redirect to the new wallet
          format.turbo_stream
          format.html { redirect_to wallet_url(@wallet), notice: "Wallet was successfully created." }
          format.json { render :show, status: :created, location: @wallet }
        end
      else

        Rails.logger.error "User save failed: #{current_user.errors.full_messages.join(', ')}"

        respond_to do |format|
          format.html do
            flash.now[:alert] = "Failed to save user: #{current_user.errors.full_messages.join(', ')}"
            render :new, status: :unprocessable_entity
          end
          format.json { render json: @wallet.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        if @wallet.save
          puts("Wallet created successfully!")
          #create a monitoring service for the wallets that are not the witholding wallet
          puts("Starting monitoring service for wallet...")
          if start_monitoring(@wallet)
            puts("Wallet monitoring started successfully!")
            format.turbo_stream
            format.html { redirect_to wallet_url(@wallet), notice: "Wallet was successfully created." }
            format.json { render :show, status: :created, location: @wallet }
          else
            #handle monitoring service failure
            @wallet.destroy #rollback wallet creation
            puts "Something went wrong.. rolling back wallet creation"
            format.html { redirect_to wallets_url, alert: "Failed to create monitoring process for wallet" }  
            format.json { render json: { error: "Failed to start monitoring service." }, status: :unprocessable_entity }
          end
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

    
    puts("Stopping monitoring service for #{@wallet}...")
    if stop_monitoring(@wallet)
      puts("Stopped monitoring process for #{@wallet} successfully!")
      puts("Destroying wallet...")
      if @wallet.destroy
        puts("Wallet #{@wallet} destroyed successfully!")

        respond_to do |format|
          format.html { redirect_to wallets_url, notice: "Wallet was successfully destroyed." }
          format.json { head :no_content }
        end
      end
    else
      format.html { redirect_to wallet_url(@wallet), alert: "Failed to stop monitoring process for wallet" }
      format.json { render json: { error: "Failed to stop monitoring service." }, status: :unprocessable_entity }
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
      params.require(:wallet).permit(:wallet_name, :wallet_address, :chain, :percentage)
    end

    def start_monitoring(wallet)
      puts "starting wallet with the private method in the wallets controller."
      wallet.start_monitoring
    rescue StandardError => e
      Rails.logger.error("Failed to start monitoring for wallet #{wallet.wallet_address}: #{e.message}")
      false 
    end

    def stop_monitoring(wallet)
      wallet.stop_monitoring
    rescue StandardError => e
      Rails.logger.error("Failed to stop monitoring for wallet #{wallet.wallet_address}: #{e.message}")
      false
    end
end





#private
#def send_data_to_track_wallet(wallet_to_monitor, withholding_wallet)
#  # Use appropriate HTTP methods and libraries to send data
#  # Example using Net::HTTP:
#  uri = URI.parse(base_url + '/api/wallet_submit')
#  http = Net::HTTP.new(uri.host, uri.port)
#  http.use_ssl = (uri.scheme == 'https') #only use https if specified;
#  request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
#  request.body = { wallet: wallet_to_monitor, withholding_wallet: withholding_wallet }.to_json
#  puts request.body.inspect
#  response = http.request(request)
#
#  # Handle response as needed
#  puts response.body
#end
#
#def send_data_to_stop_tracking_wallet(wallet)
#  # Use appropriate HTTP methods and libraries to send data
#  # Example using Net::HTTP:
#  uri = URI.parse(base_url + '/api/wallet_stop')
#  http = Net::HTTP.new(uri.host, uri.port)
#  http.use_ssl = (uri.scheme == 'https') #only use https if specified;
#  request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
#  request.body = wallet.to_json
#  puts request.body.inspect
#  response = http.request(request)
#
#  # Handle response as needed
#  puts response.body
#end
#
#def get_pending_transactions(current_user)
#    @user_id = current_user.id
#    @user_withholding_wallet = current_user.withholding_wallet
#    uri = URI.parse("#{base_url}/api/pending_transactions/#{@user_id}")
#    http = Net::HTTP.new(uri.host, uri.port)
#    http.use_ssl = (uri.scheme == 'https') #only use https if specified;
#    request = Net::HTTP::Get.new(uri.request_uri)
#    response = http.request(request)
#    @pending_transactions = JSON.parse(response.body)
#
#    puts "Pending Transactions: " + @pending_transactions.inspect
#end
#
#def base_url
#  'http://127.0.0.1:5000'
#  #'https://server.taxolotl.xyz'
#end
