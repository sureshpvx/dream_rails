class Transaction < ApplicationRecord
  enum :transaction_type, {
    signup_bonus: "signup_bonus",
    entry_fee: "entry_fee",
    prize: "prize",
    refund: "refund",
    admin_adjustment: "admin_adjustment"
  }, validate: true

  belongs_to :user
  belongs_to :reference, polymorphic: true, optional: true

  validates :amount, :balance_after, numericality: true
  validates :description, length: { maximum: 255 }, allow_blank: true

  def readonly?
    persisted?
  end

  before_destroy :prevent_destroy

  private

  def prevent_destroy
    raise ActiveRecord::ReadOnlyRecord, "Transactions are immutable"
  end
end
