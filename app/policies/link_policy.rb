# frozen_string_literal: true

module EtaShare
  # Policy to determine if an account can view a particular link
  class LinkPolicy
    def initialize(account, link, auth_scope = nil)
      @account = account
      @link = link
      @auth_scope = auth_scope
    end

    def can_view?
      return true if can_read? && (account_is_owner? && link_is_valid?)
      return true if can_read? && (account_is_accessor? && link_is_valid? && not_one_time?)
      return true if can_read? && (account_is_accessor? && link_is_valid? && one_time? && not_clicked?)

      false
    end

    def can_edit?
      can_write? && account_is_owner?
    end

    def can_delete?
      can_write? && account_is_owner?
    end

    def can_leave?
      account_is_accessor?
    end

    def can_add_files?
      can_write? && account_is_owner?
    end

    def can_remove_files?
      can_write? && account_is_owner?
    end

    def can_add_accessors?
      return true if can_write? && (account_is_owner? && not_one_time?)
      return true if can_write? && (account_is_owner? && one_time? && @link.accessors.count < 1)

      false
    end

    def can_remove_accessors?
      can_write? && (account_is_owner? && not_one_time?)
    end

    def can_access?
      !((account_is_owner? or account_is_accessor?))
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_files: can_add_files?,
        can_delete_files: can_remove_files?,
        can_add_accessors: can_add_accessors?,
        can_remove_accessors: can_remove_accessors?,
        can_access: can_access?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('links') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('links') : false
    end

    def account_is_owner?
      @link.owner == @account
    end

    def link_is_valid?
      # Time.now() should be less than the validity period
      return true if @link.valid_period.to_i.zero?

      date = Date.parse(@link.created_at.to_s)
      valid = date + @link.valid_period.to_i
      (Time.now - valid.to_time).negative?
    end

    def one_time?
      @link.one_time.to_i == 1
    end

    def not_one_time?
      @link.one_time.to_i != 1
    end

    def account_is_accessor?
      @link.accessors.include?(@account)
    end

    def not_clicked?
      @link.is_clicked.to_i != 1
    end
  end
end
