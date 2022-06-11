# frozen_string_literal: true

module EtaShare
  # Policy to determine if an account can view a particular link
  class AccessRequestPolicy
    def initialize(link, requestor_account, target_account, auth_scope = nil)
      @link = link
      @requestor_account = requestor_account
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = LinkPolicy.new(requestor_account, link, auth_scope)
      @target = LinkPolicy.new(target_account, link, auth_scope)
    end

    def can_invite?
      can_write? &&
        (@requestor.can_add_accessors? && @target.can_access?)
    end

    def can_remove?
      can_write? && @requestor.can_remove_accessors?
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('links') : false
    end

    def target_is_accessor?
      @link.accessors.include?(@target_account)
    end
  end
end
