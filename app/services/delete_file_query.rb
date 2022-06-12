# frozen_string_literal: true

module EtaShare
  # Add a collaborator to another owner's existing link
  class DeleteFileQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to delete  files'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot delete a file with those attributes'
      end
    end

    def self.call(account:, link:, file:)
      # binding.pry
      policy = LinkPolicy.new(account, link)
      raise ForbiddenError unless policy.can_remove_files?

      link.remove_file(file)
    end
  end
end
