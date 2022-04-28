# frozen_string_literal: true

require 'json'
require 'sequel'

module EtaShare
  # Models a secret document
  class File < Sequel::Model
    many_to_one :link

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :description

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'file',
            attributes: {
              id:,
              name:,
              description:
            }
          },
          included: {
            link:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
