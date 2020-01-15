# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  unsubscrided    :boolean
#  unsubscrided_at :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  line_id         :string           not null
#

class User < ApplicationRecord
  has_one :game_session

  include UserSession

  class << self

    # ユーザ登録
    #
    # @param [line_id] @event.source.user_id
    #
    # @ return [user] インスタンス
    def register(line_id)
      create(line_id: line_id)
    end
  end
end
