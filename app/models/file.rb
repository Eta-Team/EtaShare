# frozen_string_literal: true

require 'json'
require 'sequel'

module EtaShare
  # Models a secret document
  class File < Sequel::Model
    many_to_one :link

    plugin :timestamps

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
