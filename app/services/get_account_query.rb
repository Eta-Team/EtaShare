# frozen_string_literal: true

module EtaShare
  # add an accessor to another owner existing link
  class GetAccountQuery
    # Error if requesting to see forbidden account
    class ForbiddenError < StandardError
      def message
        'You do not have access to that link'
      end
    end

    def self.call(requestor:, username:)
      account = Account.first(username:)
      policy = AccountPolicy.new(requestor, account)
      policy.can_view? ? account : raise(ForbiddenError)
    end
  end
end
