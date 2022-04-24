# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test File Handling' do
  before do
    wipe_database

    DATA[:links].each do |link_data|
      EtaShare::Link.create(link_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    file_data = DATA[:files][1]
    link = EtaShare::Link.first
    new_file = link.add_file(file_data)

    file = EtaShare::File.find(id: new_file.id)
    _(file.name).must_equal file_data['name']
    _(file.description).must_equal file_data['description']
  end

  it 'SECURITY: should not use deterministic integers' do
    file_data = DATA[:files][1]
    link = EtaShare::Link.first
    new_file = link.add_file(file_data)

    _(new_file.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    file_data = DATA[:files][1]
    link = EtaShare::Link.first
    new_file = link.add_file(file_data)
    stored_file = app.DB[:files].first

    _(stored_file[:description_secure]).wont_equal new_file.description
  end
end
