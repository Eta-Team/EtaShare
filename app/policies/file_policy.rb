# frozen_string_literal: true

# Policy to determine if account can view a link

class FilePolicy
  def initialize(account, file)
    @account = account
    @file = file
  end

  def can_view?
    account_owns_link? || account_has_access_to_link?
  end

  def can_delete?
    account_owns_link?
  end

  def summary
    can_view: can_view?
    can_delete: can_delete?
  end

  private

  def account_owns_link?
    @file.link.owner == @account
  end

  def account_has_access_to_link?
    @file.link.accessors.include?(@account)
  end
end
