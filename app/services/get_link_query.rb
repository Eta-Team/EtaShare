# frozen_string_literal: true

module EtaShare
  # add accessor to an existing owner link
  class GetLinkQuery
    # Error for owner not accessor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that link'
      end
    end

    # Error for can not find a link
    class NotFoundError < StandardError
      def message
        'We could not find that link'
      end
    end

    def self.call(auth:, link:)
      raise NotFoundError unless link

      policy = LinkPolicy.new(auth[:account], link, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      if link.one_time.to_i == 1 && link.owner != auth[:account]
        EtaShare::Link.where(identifier: link.identifier).update(is_clicked: 1)
      end

      link.full_details.merge(policies: policy.summary)
    end
  end
end
