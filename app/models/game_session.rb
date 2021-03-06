# == Schema Information
#
# Table name: game_sessions
#
#  id               :integer          not null, primary key
#  answer_situation :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#
# Indexes
#
#  index_game_sessions_on_user_id  (user_id)
#

class GameSession < ApplicationRecord
  has_one :user

  class << self
    def new_session(user_id)
      create(user_id: user_id, answer_situation: default_answer_situation)
    end

    private

    # 未解答、解答済みかどうかを変換する
    #
    # @param [in<(string || integer) || boolean>]
    #
    # @return [out<string || boolean>] 引数と逆のクラス
    #   '0' <=> false
    #   '1' <=> true
    #   DEFAULT => '0'
    #
    def answer_bit(param = false)
      bit = [false, true]

      case param
      when Integer, String
        bit[param.to_i]
      when TrueClass, FalseClass
        bit.index(param).to_s
      end
    end

    def default_answer_situation
      answer_bit * Station.count
    end
  end

  # 駅ごとの情報を返す
  #
  # @return [answer_situation<Hash>, ...]
  #   id      : 1,
  #   name    : '東京',
  #   answered: false
  #
  def stations_answer_situation
    stations = Station.all
    answer_situation.chars
                    .each.with_index
                    .map do |flag, index|
                      {
                        id: stations[index].id,
                        name: stations[index].name,
                        answered: answer_bit(flag)
                      }
                    end
  end

  # 指定した駅が解答済みか？
  #
  # @param [keyword] 名前 || id
  # @return [unanswered]
  # @raise [NoMethodError] キーワードが不正な場合(正：東京, 誤：高輪ゲートウェイ, nilなど)
  def unanswered_station?(keyword)
    station =
      case keyword
      when Integer
        stations_answer_situation[keyword - 1]
      when String
        stations_answer_situation.select do |hash|
          hash[:name] == keyword
        end.first
      end
    !station[:answered]
  end

  # 解答を判定する。
  #
  # @param [station_id] Station.id
  #
  # @return [correct<boolean>]
  def judge_answer(station_id)
    return false unless unanswered_station?(station_id)

    answer(station_id) && true
  end

  # 全て解答済み?
  def answered_all?
    stations_answer_situation.all? do |hash|
      hash[:answered] == true
    end
  end

  def answer_by_npc
    npc_ans_station = stations_answer_situation.select do |sta|
      sta[:answered] == false
    end.sample

    return false unless npc_ans_station

    answer(npc_ans_station[:id])
    npc_ans_station[:name]
  end

  private

  def answer(station_id)
    answer_situation[station_id - 1] = answer_bit(true).to_s
    save
  end

  def answer_bit(param)
    GameSession.__send__ :answer_bit, param
  end
end
