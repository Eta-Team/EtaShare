# frozen_string_literal: true

module EtaShare
  # Add a accessor to a sender link
  class AddAccessor
    # Error for sender cannot be accessor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as accessor'
      end
    end

    def self.call(account:, link:, accessor_email:)
      invitee = Account.first(email: accessor_email)
      policy  = AccessRequestPolicy.new(link, account, invitee)
      raise ForbiddenError unless policy.can_invite?

      link.add_accessor(invitee)
    end
  end
end
