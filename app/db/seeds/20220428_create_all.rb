# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, links, files'
    create_accounts
    create_links
    create_files
    add_accessors
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
SENDER_INFO = YAML.load_file("#{DIR}/senders_links.yml")
LINK_INFO = YAML.load_file("#{DIR}/links_seed.yml")
FILE_INFO = YAML.load_file("#{DIR}/files_seed.yml")
ACCESSOR_INFO = YAML.load_file("#{DIR}/links_accessors.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    EtaShare::Account.create(account_info)
  end
end

def create_links
  SENDER_INFO.each do |sender|
    account = EtaShare::Account.first(username: sender['username'])
    sender['link_desc'].each do |link_desc|
      link_data = LINK_INFO.find { |link| link['description'] == link_desc }
      EtaShare::CreateLinkForSender.call(
        sender_id: account.id, link_data:
      )
    end
  end
end

def create_files
  file_info_each = FILE_INFO.each
  links_cycle = EtaShare::Link.all.cycle
  loop do
    file_info = file_info_each.next
    link = links_cycle.next
    EtaShare::CreateFileForLink.call(
      link_id: link.id, file_data: file_info
    )
  end
end

def add_accessors
  access_info = ACCESSOR_INFO
  access_info.each do |access|
    link = EtaShare::Link.first(description: access['link_desc'])
    access['accessor_email'].each do |email|
      EtaShare::AddAccessorToLink.call(
        email:, link_id: link.id
      )
    end
  end
end
