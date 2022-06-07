# frozen_string_literal: true

module EtaShare
  # Policy to determine if an account can view a particular link
  class AccessRequestPolicy
    def initialize(link, requestor_account, target_account)
      @link = link
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = LinkPolicy.new(requestor_account, link)
      @target = LinkPolicy.new(target_account, link)
    end

    def can_invite?
      @requestor.can_add_accessors? && @target.can_access?
    end

    def can_remove?
      @requestor.can_remove_accessors?
    end

    private

    def target_is_accessor?
      @link.accessors.include?(@target_account)
    end
  end
end
