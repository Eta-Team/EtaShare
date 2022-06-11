# frozen_string_literal: true

module EtaShare
  # Add accessor to another owner's existing link
  class GetFileQuery
    # Error for owner can not be accessor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access this file'
      end
    end

    # Error can not find a link
    class NotFoundError < StandardError
      def message
        'We could not find that file'
      end
    end

    # File for given requestor account
    def self.call(auth:, file:)
      raise NotFoundError unless file

      policy = FilePolicy.new(auth[:account], file, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      file
    end
  end
end
