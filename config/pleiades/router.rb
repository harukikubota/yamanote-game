Pleiades::Command::Router.class_eval do
  include CommandCommon
end

Pleiades::Command::Router.route do
  nest_blocks only_events: %i[follow unfollow], scope: 'users' do
    event action: __event_name__
    return
  end

  scope :game do
    if user.session?
      text action: 'close', pattern: '終了'
      text action: 'answer', pattern: //
    end
    text action: 'start', pattern: 'ゲーム開始'
  end
end
