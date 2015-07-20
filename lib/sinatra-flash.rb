module Sinatra
  module Flash
    module Style
      def styled_flash(key = :flash)
        return '' if flash(key).empty?
        id = (key == :flash ? 'flash' : "flash_#{key}")
        close = '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">×</span></button>'
        messages = flash(key).collect { |message| "  <div class='alert alert-#{message[0]} fade in' role='alert'>#{close}\n <p>#{message[1]}</p></div>\n" }

        return "<div id='#{id}'>\n" + messages.join + "</div>"
      end
    end
  end
end
