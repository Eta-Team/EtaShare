# frozen_string_literal: true

module EtaShare
  class LinkPolicy
    def initialize(account, link)
      @account = account
      @link = link
    end

    def can_view?
      account_is_owner? || account_is_accessor?
    end

    def can_edit?
      account_is_owner?
    end

    def can_delete?
      account_is_owner?
    end

    def can_leave?
      account_is_accessor?
    end

    def can_add_files?
      account_is_owner?
    end

    def can_remove_files?
      account_is_owner?
    end

    def can_add_accessors?
      account_is_owner?
    end

    def can_remove_accessors?
      account_is_owner?
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
        can_remove_files: can_remove_files?,
        can_add_accessors: can_add_accessors?,
        can_remove_accessors: can_remove_accessors?,
        can_access: can_access?
      }
    end
  end
end
