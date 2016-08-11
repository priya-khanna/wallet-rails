class BaseService
  include ActiveModel::Validations

  def initialize user, params, opts={}
    @user = user
    @params = params.dup.with_indifferent_access
    @opts = opts.with_indifferent_access
    @result = nil
  end

  def update_without_transaction
    raise "Not implemented"
  end

  def update
    return false unless valid?
    ActiveRecord::Base.transaction do
      return true if update_without_transaction
      raise ActiveRecord::Rollback
    end
    self.errors.add(:base, "General failure updating resource") if errors.blank?
    false
  end

  attr_reader :result
  private
  attr_reader :user, :params, :opts
  attr_writer :result

  def merge_errors_from(item)
    item.errors.full_messages.each do |error|
      self.errors.add(:base, error)
    end
    false
  end
end