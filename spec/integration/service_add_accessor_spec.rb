# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddAccessorToLink service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      EtaShare::Account.create(account_data)
    end

    link_data = DATA[:links].first

    @sender = EtaShare::Account.all[0]
    @accessor = EtaShare::Account.all[1]
    @link = EtaShare::CreateLinkForOwner.call(
      owner_id: @sender.id, link_data:
    )
  end

  it 'HAPPY: should be able to add an accessor to a link' do
    EtaShare::AddAccessorToLink.call(
      email: @accessor.email,
      link_id: @link.id
    )

    _(@accessor.links.count).must_equal 1
    _(@accessor.links.first).must_equal @link
  end

  it 'BAD: should not add sender as an accessor' do
    _(proc {
      EtaShare::AddAccessorToLink.call(
        email: @sender.email,
        link_id: @link.id
      )
    }).must_raise EtaShare::AddAccessorToLink::SenderNotAccessorError
  end
end
