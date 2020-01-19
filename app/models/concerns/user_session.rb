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
    raise StandardError, 'Already started session.' if session

    GameSession.new_session(id) && reload
  end

  def session_destroy
    require_session!

    session.destroy && reload
  end

  def answered_all?
    require_session!

    session.answered_all?
  end

  def answer(station_id)
    require_session!

    session.judge_answer(station_id)
  end

  private

  def require_session!
    raise 'Session unstarted.' unless session?
  end
end
