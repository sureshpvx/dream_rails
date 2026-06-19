class User < ApplicationRecord
  STARTING_BALANCE = BigDecimal("10000.00")

  class InsufficientBalance < StandardError; end

  has_many :contests, foreign_key: :created_by_id, inverse_of: :created_by, dependent: :nullify
  has_many :notifications, dependent: :destroy
  has_many :transactions, class_name: "Transaction", dependent: :restrict_with_exception
  has_many :user_teams, dependent: :destroy

  before_validation :normalize_email

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :encrypted_password, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false },
    length: { in: 3..20 },
    format: { with: /\A[a-zA-Z0-9_]+\z/, message: "can only contain letters, numbers, and underscores" }
  validates :virtual_balance, numericality: { greater_than_or_equal_to: 0 }
  validates :country_code, length: { is: 2 }
  validate :must_be_adult, if: :date_of_birth?
  validate :must_be_in_permitted_region

  scope :active, -> { where(is_active: true) }

  def display_name
    username.presence || email
  end

  def credit!(amount:, transaction_type:, description:, reference: nil, metadata: {})
    adjust_balance!(
      amount: BigDecimal(amount.to_s),
      transaction_type: transaction_type,
      description: description,
      reference: reference,
      metadata: metadata
    )
  end

  def debit!(amount:, transaction_type:, description:, reference: nil, metadata: {})
    positive_amount = BigDecimal(amount.to_s)
    raise ArgumentError, "amount must be positive" unless positive_amount.positive?

    adjust_balance!(
      amount: -positive_amount,
      transaction_type: transaction_type,
      description: description,
      reference: reference,
      metadata: metadata
    )
  end

  private

  def adjust_balance!(amount:, transaction_type:, description:, reference:, metadata:)
    self.class.transaction do
      lock!
      next_balance = virtual_balance + amount
      raise InsufficientBalance, "Insufficient balance. Add more play money." if next_balance.negative?

      update!(virtual_balance: next_balance)
      transactions.create!(
        amount: amount,
        transaction_type: transaction_type,
        reference: reference,
        balance_after: next_balance,
        description: description,
        metadata: metadata
      )
    end
  end

  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def must_be_adult
    return if date_of_birth <= 18.years.ago.to_date

    errors.add(:date_of_birth, "You must be 18 or older to play.")
  end

  def must_be_in_permitted_region
    return unless GeolocationService.blocked?(country_code: country_code, state_code: state_code)

    errors.add(:base, "Fantasy sports is not available in your region.")
  end
end
