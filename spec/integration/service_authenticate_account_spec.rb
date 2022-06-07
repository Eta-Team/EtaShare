# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddAccessorToLink service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      EtaShare::Account.create(account_data)
    end
  end

  it 'HAPPY: should authenticate valid account credentials' do
    credentials = DATA[:accounts].first
    account = EtaShare::AuthenticateAccount.call(
      username: credentials['username'], password: credentials['password']
    )
    _(account).wont_be_nil
  end

  it 'SAD: will not authenticate with invalid password' do
    credentials = DATA[:accounts].first
    _(proc {
      EtaShare::AuthenticateAccount.call(
        username: credentials['username'], password: 'wrongword'
      )
    }).must_raise EtaShare::AuthenticateAccount::UnauthorizedError
  end

  it 'BAD: will not authenticate with invalid credentials' do
    _(proc {
      EtaShare::AuthenticateAccount.call(
        username: 'wronguser', password: 'wrongword'
      )
    }).must_raise EtaShare::AuthenticateAccount::UnauthorizedError
  end
end
