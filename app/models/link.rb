# frozen_string_literal: true

require 'json'
require 'sequel'

module EtaShare
  # Models a project
  class Link < Sequel::Model
    one_to_many :files
    plugin :association_dependencies, files: :destroy

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'link',
            attributes: {
              id:,
              title:,
              description:,
              is_clicked:,
              valid_period:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
