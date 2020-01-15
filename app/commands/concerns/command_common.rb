module CommandCommon
  extend ActiveSupport::Concern
  include Pleiades::Client

  included do
    def current_user
      @user ||= User.find_by_line_id(@event.source.user_id)
    end
    alias_method :user, :current_user
  end
end
