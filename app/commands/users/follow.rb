module Users
  class Follow < BaseCommand
    def call
      User.register(@event.source.user_id)
      message = { type: :text, text: '友達登録ありがとうござます' }
      client.reply_message(@event.reply_token, message)
    end
  end
end
