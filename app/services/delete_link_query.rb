# frozen_string_literal: true

module EtaShare
  # Add an accessor to another owner's existing link
  class DeleteLinkQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to delete that link'
      end
    end

    # Error for cannot find a link
    class NotFoundError < StandardError
      def message
        'We could not find that link'
      end
    end

    def self.call(auth:, link:)
      raise NotFoundError unless link

      policy = LinkPolicy.new(auth[:account], link, auth[:scope])
      raise ForbiddenError unless policy.can_delete?

      delete(link)
    end

    def self.delete(link)
      link.files_dataset.destroy if link.files.count.positive?
      link.remove_all_accessors if link.accessors.count.positive?
      #   binding.pry
      EtaShare::Link.where(identifier: link.identifier)
                    .delete
    end
  end
end
