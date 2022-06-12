# frozen_string_literal: true

# Policy to determine if account can view a file
class FilePolicy
  def initialize(account, file, auth_scope = nil)
    @account = account
    @file = file
    @auth_scope = auth_scope
  end

  def can_view?
    can_read? && (account_owns_link? || account_has_access_to_link?)
  end

  def can_delete?
    can_write? && account_owns_link?
  end

  def summary
    {
      can_view: can_view?,
      can_delete: can_delete?
    }
  end

  private

  def can_read?
    @auth_scope ? @auth_scope.can_read?('files') : false
  end

  def can_write?
    @auth_scope ? @auth_scope.can_write?('files') : false
  end

  def account_owns_link?
    @file.link.owner == @account
  end

  def account_has_access_to_link?
    @file.link.accessors.include?(@account)
  end
end
