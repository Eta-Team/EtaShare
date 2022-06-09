# frozen_string_literal: true

module EtaShare
  # Maps Google account details to attributes
  class GoogleAccount
    def initialize(g_account)
      @g_account = g_account
    end

    def username
      "#{@g_account['name']}@google"
    end

    def email
      @g_account['email']
    end

    def picture
      @g_account['picture']
    end
  end
end
