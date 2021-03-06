# frozen_string_literal: true

module EtaShare
  # add accessor to another owner existing link
  class RemoveAccessor
    # Error for owner can not be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(auth:, accessor_email:, link_id:)
      link = Link.first(identifier: link_id)
      accessor = Account.first(email: accessor_email)

      policy = AccessRequestPolicy.new(
        link, auth[:account], accessor, auth[:scope]
      )
      raise ForbiddenError unless policy.can_remove?

      link.remove_accessor(accessor)
      accessor
    end
  end
end
