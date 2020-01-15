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

    # 未解答、解答済みかどうかを変換する
    #
    # @param [in<string || boolean>]
    #
    # @return [out<string || boolean>] 引数と逆のクラス
    #   '0' <=> false
    #   '1' <=> true
    #   DEFAULT => '0'
    #
    def answer_bit(param = false)
      bit = [false, true]

      case param
      when Integer
        bit[param]
      when TrueClass, FalseClass
        bit.index(param).to_s
      end
    end

    private

    def default_answer_situation
      answer_bit * Station.count
    end
  end

  # 駅ごとの情報を返す
  #
  # @return [answer_situation<Hash>, ...]
  #   name: '東京',
  #   romaji: 'tokyo',
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
                        answered: convert_num_to_ans_flag(flag)
                      }
                    end
  end

  # answer_situation の数値を変換する。
  #
  # @param  [number]     0   ||  1
  # @return [answered] false || true
  def convert_num_to_ans_flag(number)
    [false, true][number.to_i]
  end

  # 指定した駅が解答済みか？
  #
  # @param [keyword] 名前 || ローマ字 || id
  # @return [unanswered]
  # @raise [NoMethodError] キーワードがStringであり、不正な文字な場合(正：tokyo, 誤：Tokyo)
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

  # 解答数
  def answered_count
    stations_answer_situation.select do |hash|
      hash[:answered]
    end.count
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

    answer(npc_ans_station[:id])
    npc_ans_station[:name]
  end

  private

  def answer(station_id)
    answer_situation[station_id - 1] = answer_bit(true).to_s
    save
  end

  def answer_bit(param)
    self.class.answer_bit(param)
  end
end
