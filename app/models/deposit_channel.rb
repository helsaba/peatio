class DepositChannel < ActiveYamlBase
  include Channelable
  include HashCurrencible
  include International

  def accounts
    bank_accounts.map {|i| OpenStruct.new(i) }
  end

  def min_confirm?(deposit_amount: Float::INFINITY, confirmation_count: 0)
    confirmation(deposit_amount).min_confirm?(confirmation_count)
  end

  def max_confirm?(deposit_amount: Float::INFINITY, confirmation_count: 0)
    confirmation(deposit_amount).max_confirm?(confirmation_count)
  end

  def safe_confirm?(deposit_amount: Float::INFINITY, confirmation_count: 0)
    default_confirmation(deposit_amount).max_confirm?(confirmation_count)
  end

  private
  def confirmations
    confirm_settings.collect {|c| Confirmation.new(c) }
  end

  def confirmation(amount)
    confirmations.find{|c| c.range.cover? amount } || default_confirmation
  end

  def default_confirmation
    c = Confirmation.new min_confirm: default_min_confirm, max_confirm: default_max_confirm
    c.range = Range.new 0, Float::INFINITY
    c
  end

  class Confirmation < ActiveHash::Base
    attr_writer :range

    field :amount
    field :min_confirm
    field :max_confirm

    def range
      @range ||= Range.new *amount.split('..').map(&:to_f), true
    end

    def min_confirm?(count)
      count >= min_confirm && count < max_confirm
    end

    def max_confirm?(count)
      count >= max_confirm
    end
  end
end
