# frozen_string_literal: true

module EtaShare
  # Maps Google account details to attributes
  class GoogleAccount
    def initialize(g_account)
      @g_account = g_account
    end

    def username
      name = @g_account['name'].to_s.force_encoding('UTF-8')
      "#{name}@google"
    end

    def email
      @g_account['email']
    end

    def picture
      @g_account['picture']
    end
  end
end
