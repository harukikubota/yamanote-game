module Users
  class Follow < BaseCommand
    def call
      message =
        if user
          'おかえりなさいませ'
        else
          User.register(@event.source.user_id)
          '友達登録ありがとうござます'
        end
      client.reply_message(@event.reply_token, { type: :text, text: message })
    end
  end
end
