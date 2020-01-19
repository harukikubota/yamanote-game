require 'rails_helper'

RSpec.describe User, type: :model do

  # 各メソッドで指定するもの
  ## caller 呼び出したいメソッド名のシンボル
  ## args   callerに設定したメソッドへ渡す引数リスト
  ## message 例外が発生する場合に、捕捉するエラーメッセージを指定する

  let(:user) { create(:user) }
  let(:call) { user.send(caller, *args) }
  let(:args) { [] }

  # Error messages.
  let(:err_session_already_started) { 'Already started session.' }
  let(:err_session_unstarted)       { 'Session unstarted.' }

  shared_examples 'to_raise' do
    it { expect { call }.to raise_error(StandardError, message) }
  end

  shared_examples 'no_raise' do
    it { expect(call).to_not be_nil }
  end

  shared_context 'user has session' do
    before(:each) { user.session_start }
  end

  describe '.create' do
    it { expect(user).to be_valid }
    it { expect(user.line_id).to eq 'UserId' }
    it { expect(user.session?).to be_falsey }
  end

  describe '#session_start' do
    let(:message) { err_session_already_started }
    let(:caller) { :session_start }

    context 'セッション未開始時' do
      it_behaves_like 'no_raise'
      it { expect(call.session?).to be_truthy }
    end

    context 'セッション中' do
      include_context 'user has session'
      it_behaves_like 'to_raise'
    end
  end

  describe '#session_destroy' do
    let(:message) { err_session_unstarted }
    let(:caller) { :session_destroy }

    context 'セッション未開始時' do
      it_behaves_like 'to_raise'
    end

    context 'セッション中' do
      include_context 'user has session'
      it_behaves_like 'no_raise'
      it { expect(call.session).to be_nil }
    end
  end

  describe '#answered_all?' do
    let(:message) { err_session_unstarted }
    let(:caller) { :answered_all? }

    context 'セッション未開始時' do
      it_behaves_like 'to_raise'
    end

    context 'セッション中' do
      include_context 'user has session'
      it_behaves_like 'no_raise'
      it { expect(call).to be_falsey }
    end
  end

  describe '#answer' do
    let(:message) { err_session_unstarted }
    let(:caller)  { :answer }
    let(:args)    { [1] }

    context 'セッション未開始時' do
      it_behaves_like 'to_raise'
    end

    context 'セッション中' do
      include_context 'user has session'
      it_behaves_like 'no_raise'
      it { expect(call).to be_truthy }
    end
  end

  describe '#require_session!' do
    let(:message) { err_session_unstarted }
    let(:caller)  { :require_session! }

    context 'セッション未開始時' do
      it_behaves_like 'to_raise'
    end

    context 'セッション中' do
      include_context 'user has session'
      it { expect(call).to be_nil }
    end
  end
end
