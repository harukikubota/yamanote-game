module Game
  class Close < BaseCommand
    def call
      user.session_destroy
      client.reply_message(@event.reply_token, {type: :text, text: "ゲームを終了しました。"})
    end
  end
end
