class WalletController < ApplicationController
  def show
    @transactions = current_user.transactions.order(created_at: :desc).limit(50)
  end
end
