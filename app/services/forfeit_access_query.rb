# frozen_string_literal: true

module EtaShare
  # Add a collaborator to another owner's existing link
  class ForfeitAccessQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed forfeit access to lin '
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot forfeit access with those attributes'
      end
    end

    def self.call(auth:, link:)
      # binding.pry
      policy = LinkPolicy.new(auth[:account], link, auth[:scope])
      raise ForbiddenError unless policy.can_leave?
      
      link.remove_accessor(auth[:account])
    end
  end
end
