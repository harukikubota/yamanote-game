module UserSession
  extend ActiveSupport::Concern

  def self.included(base)
    base.class_eval do
      alias_method :session, :game_session
    end
  end

  # user has started session?
  def session?
    session ? true : false
  end

  def session_start
    GameSession.new_session(id)
  end

  def session_destroy
    session.destroy
  end

  def answered_all?
    session.answered_all?
  end

  def answer(station_id)
    session.judge_answer(station_id)
  end
end
