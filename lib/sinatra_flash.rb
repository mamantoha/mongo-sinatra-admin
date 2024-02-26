# frozen_string_literal: true

module Sinatra
  module Flash
    module Style # :nodoc:
      def styled_flash(key = :flash)
        return '' if flash(key).empty?

        id = (key == :flash ? 'flash' : "flash_#{key}")
        close = '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>'

        messages = flash(key).collect do |message|
          "  <div class='alert alert-#{message[0]} alert-dismissible fade show' role='alert'>\n <span>#{message[1]}</span>\n#{close}</div>\n"
        end

        "<div id='#{id}'>\n#{messages.join}</div>"
      end
    end
  end
end
