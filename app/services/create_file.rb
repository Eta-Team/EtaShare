# frozen_string_literal: true

module EtaShare
  # Create new configuration for a link
  class CreateFile
    # Error for owner can not be accessor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more files'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Can not create a file with those attributes'
      end
    end

    def self.call(auth:, link:, file_data:)
      policy = LinkPolicy.new(auth[:account], link, auth[:scope])
      raise ForbiddenError unless policy.can_add_files?

      add_file(link, file_data)
    end

    def self.add_file(link, file_data)
      link.add_file(file_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
