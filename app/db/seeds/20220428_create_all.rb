# frozen_string_literal: true

require './app/controllers/helpers'
include EtaShare::SecureRequestHelpers

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, links, files'
    create_accounts
    create_owned_links
    create_files
    add_accessors
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_links.yml")
LINK_INFO = YAML.load_file("#{DIR}/links_seed.yml")
FILE_INFO = YAML.load_file("#{DIR}/files_seed.yml")
ACCESSOR_INFO = YAML.load_file("#{DIR}/links_accessors.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    EtaShare::Account.create(account_info)
  end
end

def create_owned_links
  OWNER_INFO.each do |owner|
    account = EtaShare::Account.first(username: owner['username'])
    owner['link_title'].each do |link_title|
      link_data = LINK_INFO.find { |link| link['title'] == link_title }
      account.add_owned_link(link_data)
    end
  end
end

def create_files
  file_info_each = FILE_INFO.each
  links_cycle = EtaShare::Link.all.cycle
  loop do
    file_info = file_info_each.next
    link = links_cycle.next
    auth_token = AuthToken.create(link.owner)
    auth = scoped_auth(auth_token)

    EtaShare::CreateFile.call(
      auth:, link:, file_data: file_info
    )
  end
end

def add_accessors
  access_info = ACCESSOR_INFO
  access_info.each do |access|
    link = EtaShare::Link.first(title: access['link_title'])

    auth_token = AuthToken.create(link.owner)
    auth = scoped_auth(auth_token)

    access['accessor_email'].each do |email|
      EtaShare::AddAccessor.call(
        auth:, link:, accessor_email: email
      )
    end
  end
end
