# frozen_string_literal: true

require 'http'

module EtaShare
  # Find or create an SsoAccount based on Github code
  class AuthorizeSso
    def initialize(config)
      @config = config
    end

    def call(id_token)
      google_account = get_google_account(id_token)
      sso_account = find_or_create_sso_account(google_account)
      account_and_token(sso_account)
    end

    def get_google_account(id_token)
      g_response = HTTP.get("#{@config.GET_USER_INFO}#{id_token}")

      raise unless g_response.status == 200

      account = GoogleAccount.new(JSON.parse(g_response))
      { username: account.username, email: account.email, picture: account.picture }
    end

    def find_or_create_sso_account(account_data)
      Account.first(email: account_data[:email]) ||
        Account.create_google_account(account_data)
    end

    def account_and_token(account)
      {
        type: 'sso_account',
        attributes: {
          account:,
          auth_token: AuthToken.create(account)
        }
      }
    end
  end
end
