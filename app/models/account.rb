# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module EtaShare
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_links, class: :'EtaShare::Link', key: :owner_id
    many_to_many :accesses,
                 class: :'EtaShare::Link',
                 join_table: :accounts_links,
                 left_key: :accessor_id, right_key: :link_id

    plugin :association_dependencies,
           owned_links: :destroy,
           accesses: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password, :picture

    plugin :timestamps, update_on_create: true

    def self.create_google_account(google_account)
      create(username: google_account[:username],
             email: google_account[:email],
             picture: google_account[:picture])
    end

    def links
      owned_links + accesses
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = EtaShare::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            username:,
            email:,
            picture:
          }
        }, options
      )
    end
  end
end
