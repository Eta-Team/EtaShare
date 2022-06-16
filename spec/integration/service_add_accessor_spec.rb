# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddAccessorToLink service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      EtaShare::Account.create(account_data)
    end

    link_data = DATA[:links].first

    @owner_data = DATA[:accounts][0]
    @owner = EtaShare::Account.all[0]
    @accessor = EtaShare::Account.all[1]
    @link = @owner.add_owned_link(link_data)
  end

  it 'HAPPY: should be able to add an accessor to a link' do
    auth = authorization(@owner_data)

    EtaShare::AddAccessor.call(
      auth:,
      link: @link,
      accessor_email: @accessor.email
    )

    _(@accessor.links.count).must_equal 1
    _(@accessor.links.first).must_equal @link
  end

  it 'BAD: should not add owner as an accessor' do
    auth = EtaShare::AuthenticateAccount.call(
      username: @owner_data['username'],
      password: @owner_data['password']
    )

    _(proc {
      EtaShare::AddAccessor.call(
        auth:,
        link: @link,
        accessor_email: @owner.email
      )
    }).must_raise EtaShare::AddAccessor::ForbiddenError
  end
end
