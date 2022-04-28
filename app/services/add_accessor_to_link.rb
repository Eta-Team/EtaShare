# frozen_string_literal: true

module EtaShare
  # Add a accessor to a sender link
  class AddAccessorToLink
    # Error for sender cannot be accessor
    class SenderNotAccessorError < StandardError
      def message = 'Sender cannot be accessor of link'
    end

    def self.call(email:, link_id:)
      accessor = Account.first(email:)
      link = Link.first(id: link_id)
      raise(SenderNotAccessorError) if link.owner.id == accessor.id

      link.add_accessor(accessor)
    end
  end
end
