module Api
  module V1
    class WalletController < ApplicationController
      def show
        render json: {
          balance: current_user.virtual_balance,
          transactions: current_user.transactions.order(created_at: :desc).limit(20)
        }
      end
    end
  end
end
