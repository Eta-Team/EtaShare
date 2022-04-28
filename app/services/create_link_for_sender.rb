# frozen_string_literal: true

module EtaShare
  # Service object to create a new link for a sender
  class CreateLinkForSender
    def self.call(sender_id:, link_data:)
      Account.find(id: sender_id)
             .add_sent_link(link_data)
    end
  end
end