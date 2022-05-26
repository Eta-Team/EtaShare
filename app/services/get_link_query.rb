# frozen_string_literal: true

module EtaShare
  # add accessor to an existing owner link
  class GetLinkQuery
    # Error for owner not accessor
    class ForbiddenError < StandardError
      def message
        'You  are not allowed to access that link'
      end
    end

    # Error for can not find a link
    class NotFoundError < StandardError
      def message
        'We could not find that link'
      end
    end

    def self.call(account:, link:)
      raise NotFoundError unless link

      policy = LinkPolicy.new(account, link)

      raise ForbiddenError unless policy.can_view?

      link.full_details.merge(policies: policy.summary)
    end
  end
end
