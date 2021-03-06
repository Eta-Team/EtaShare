# frozen_string_literal: true

require 'json'
require 'sequel'

module EtaShare
  # Models a project
  class Link < Sequel::Model
    many_to_one :owner, class: :'EtaShare::Account'

    many_to_many :accessors,
                 class: :'EtaShare::Account',
                 join_table: :accounts_links,
                 left_key: :link_id, right_key: :accessor_id

    one_to_many :files

    plugin :association_dependencies,
           files: :destroy,
           accessors: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :title, :is_clicked, :description, :valid_period, :one_time, :identifier

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def valid_period
      SecureDB.decrypt(valid_period_secure)
    end

    def valid_period=(plaintext)
      self.valid_period_secure = SecureDB.encrypt(plaintext)
    end

    def to_h
      {
        type: 'link',
        attributes: {
          identifier:,
          title:,
          description:,
          one_time:,
          valid_period:,
          owner:,
          created_at:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner:,
          accessors:,
          files:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
