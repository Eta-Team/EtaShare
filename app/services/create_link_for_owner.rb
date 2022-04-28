# frozen_string_literal: true

module EtaShare
  # Service object to create a new link for a sender
  class CreateLinkForOwner
    def self.call(owner_id:, link_data:)
      Account.find(id: owner_id)
             .add_owned_link(link_data)
    end
  end
end
