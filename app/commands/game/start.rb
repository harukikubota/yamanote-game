module Game
  class Start < BaseCommand
    def call
      user.session_start
      client.reply_message(@event.reply_token, {type: :text, text: "ゲームを開始しました。駅名を入力してください"})
      p user.session.stations_answer_situation
    end
  end
end
