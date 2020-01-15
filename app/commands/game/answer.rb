module Game
  class Answer < BaseCommand
    def call
      return retry_message unless station_name?

      ans_ret = user.answer(users_answer_station.id)

      ans_ret ? correct! : incorrect
    end

    def retry_message
      client.reply_message(@event.reply_token, {type: :text, text: "無効な入力値です。駅名を入力してください。"})
    end

    def correct!
      message =
        if user.answered_all?
          user.session_destroy
          '全部答えたので終了です。'
        else
          user.session.answer_by_npc
        end

      client.reply_message(@event.reply_token, { type: :text, text: message })
    end

    def incorrect
      user.session_destroy
      message = 'すでに答えた駅名です。ゲームを終了します。'
      client.reply_message(@event.reply_token, { type: :text, text: message })
    end

    def station_name?
      users_answer_station.present?
    end

    def users_answer_station
      @_station ||= Station.where(name: @event.text).first
    end
  end
end
