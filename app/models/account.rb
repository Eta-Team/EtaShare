# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module EtaShare
  STORE_DIR = 'app/db/store'

  # Holds a full secret account
  class Account
    # Creates a new account by passing in hash of attributes
    def initialize(new_account)
      @id          = new_account['id'] || new_id
      @username    = new_account['username']
      @password    = new_account['password']
    end

    attr_reader :id, :username, :password

    def to_json(options = {})
      JSON(
        {
          type: 'document',
          id:,
          username:,
          password:
        },
        options
      )
    end

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(EtaShare::STORE_DIR) unless Dir.exist? EtaShare::STORE_DIR
    end

    # Stores account in file store
    def save
      File.write("#{EtaShare::STORE_DIR}/#{id}.txt", to_json)
    end

    # Query method to find one account
    def self.find(find_id)
      account_file = File.read("#{EtaShare::STORE_DIR}/#{find_id}.txt")
      Account.new JSON.parse(account_file)
    end

    # Query method to retrieve index of all documents
    def self.all
      Dir.glob("#{EtaShare::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(EtaShare::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
