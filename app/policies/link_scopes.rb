# frozen_string_literal: true

module EtaShare
  # Policy to determine if account can view a link
  class LinkPolicy
    # Scope of link policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_links(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |link|
            includes_accessor?(link, @current_account)
          end
        end
      end

      private

      def all_links(account)
        # all_valid(account.owned_links, account)
        # all_valid(account.accesses, account)
        account.owned_links + account.accesses
      end

      def includes_accessor?(link, account)
        link.accessors.include? account
      end

      def all_valid(links, account)
        links.each do |link|
          date = Date.parse(link.created_at.to_s)
          valid = date + link.valid_period.to_i
          remove_link(link) if (Time.now - valid.to_time).positive?
        end
        account.owned_links + account.accesses
      end

      def remove_link(link)
        remove_files(link.files)
        EtaShare::Link.find(id: link.id).delete
      end

      def remove_files(files)
        files.each do |file|
          EtaShare::File.find(id: file.id).delete
        end
      end
    end
  end
end
