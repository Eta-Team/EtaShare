# frozen_string_literal: true

module EtaShare
  # Add an accessor to another owner's existing link
  class UpdateLinkQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to edit that link'
      end
    end

    # Error for cannot find a link
    class NotFoundError < StandardError
      def message
        'We could not find that link'
      end
    end

    def self.call(account:, link:, link_data:)
      raise NotFoundError unless link

      policy = LinkPolicy.new(account, link)
      raise ForbiddenError unless policy.can_edit?

      update_link(link, link_data)
      link.full_details.merge(policies: policy.summary)
    end

    def self.update_link(link, link_data)
      title = link_data['title']
      description = link_data['description']
      valid = link_data['valid_period']
      # link.title = title unless title.nil?
      # link.description_secure = SecureDB.encrypt(description) unless description.nil?
      # link.valid_period_secure = SecureDB.encrypt(valid) unless description.nil?
      # binding.pry
      EtaShare::Link.where(identifier: link.identifier)
                    .update(title:,
                            description_secure: SecureDB.encrypt(description),
                            valid_period_secure: SecureDB.encrypt(valid))
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
