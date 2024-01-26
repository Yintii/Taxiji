json.extract! wallet, :id, :wallet_name, :wallet_address, :created_at, :updated_at
json.url wallet_url(wallet, format: :json)
