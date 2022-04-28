# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(accessor_id: :accounts, link_id: :links)
  end
end
