# frozen_string_literal: true

module EtaShare
  # Service object to create a new link for an owner
  class CreateLinkForOwner
    # Error for owner cannot create new link
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create a new link'
      end
    end

    def self.call(auth:, link_data:)
      raise ForbiddenError unless auth[:scope].can_write?('links')

      identifier = SecureDB.generate_key.tr('/', '-')
      # link_data['identifier'] = identifier
      # auth[:account].add_owned_link(link_data)
      link = Link.create(identifier: 'lol',
                         title: link_data['title'],
                         description_secure: SecureDB.encrypt(link_data['description']),
                         valid_period_secure: SecureDB.encrypt(link_data['valid']))
      auth[:account].add_owned_link(link)
    end
  end
end
