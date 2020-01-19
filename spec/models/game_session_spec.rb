require 'rails_helper'

RSpec.describe GameSession, type: :model do
  let(:user) { create(:user) }
  let!(:session) { GameSession.new_session(user.id) }

  # 東京が解答済み
  shared_context 'answered one' do
    before(:each) { session.__send__ :answer, 1 }
  end

  # 東京、神田が解答済み
  shared_context 'answered two' do
    before(:each) { 2.times { |n| session.__send__ :answer, n + 1 } }
  end

  shared_context 'answered all' do
    before(:each) { Station.count.times { |id| session.__send__ :answer, id + 1 } }
  end

  describe '.new_session' do
    it 'レコードが作成されていること' do
      expect(session).to be_valid
    end

    it '指定したユーザのレコードとして作成されていること' do
      expect(session.id).to eq user.session.id
    end

    it '解答状況がデフォルト値であること' do
      expect(session.answer_situation).to eq '0' * 3
    end
  end

  shared_examples 'got' do |arg, result|
    it { expect(GameSession.__send__(:answer_bit, arg)).to eq result }
  end

  describe '.answer_bit' do
    it_behaves_like 'got', false, '0'
    it_behaves_like 'got',  true, '1'
    it_behaves_like 'got',   '0', false
    it_behaves_like 'got',     1, true
  end

  describe '.default_answer_situation' do
    subject { GameSession.__send__(:default_answer_situation) }
    it { is_expected.to eq '0' * 3 }
  end

  describe '#stations_answer_situation' do
    let(:result) { session.stations_answer_situation }
    let(:stations) { Station.all }

    context '初期状態' do
      it '3件のデータを取得できること' do
        expect(result.count).to eq 3
      end

      it 'idがレコードの値と等しいこと' do
        expect(result[0][:id]).to eq stations[result[0][:id] - 1].id
        expect(result[1][:id]).to eq stations[result[1][:id] - 1].id
        expect(result[2][:id]).to eq stations[result[2][:id] - 1].id
      end

      it '名前が正しく設定されていること' do
        expect(result[0][:name]).to eq stations[result[0][:id] - 1].name
        expect(result[1][:name]).to eq stations[result[1][:id] - 1].name
        expect(result[2][:name]).to eq stations[result[2][:id] - 1].name
      end

      it '全て未解答であること' do
        expect(result[0][:answered]).to be_falsey
        expect(result[1][:answered]).to be_falsey
        expect(result[2][:answered]).to be_falsey
      end
    end

    context '1件解答済み' do
      include_context 'answered one'

      it '東京が解答されていること' do
        expect(result[0][:answered]).to be_truthy
      end

      it '他の駅は未解答であること' do
        expect(result[1][:answered]).to be_falsey
        expect(result[2][:answered]).to be_falsey
      end
    end

    context '全て解答済み' do
      include_context 'answered all'

      it '全て解答されていること' do
        expect(result[0][:answered]).to be_truthy
        expect(result[1][:answered]).to be_truthy
        expect(result[2][:answered]).to be_truthy
      end
    end
  end

  shared_examples 'to_raise_no_permit_arg' do |arg|
    it { expect { session.unanswered_station?(arg) }.to raise_error(NoMethodError) }
  end

  shared_examples 'unanswer?' do |flag, sta_id|
    it { expect(session.unanswered_station?(sta_id)).to eq flag }
  end

  describe '#unanswered_station?' do
    context '引数に無効な値を渡す' do
      it_behaves_like 'to_raise_no_permit_arg', nil
      it_behaves_like 'to_raise_no_permit_arg', 500
      it_behaves_like 'to_raise_no_permit_arg', '今日の晩ご飯はハンバーグ'
    end

    context '初期状態' do
      it_behaves_like 'unanswer?', true, '東京'
      it_behaves_like 'unanswer?', true, '神田'
      it_behaves_like 'unanswer?', true, '上野'
    end

    context '一件解答済み' do
      include_context 'answered one'
      it_behaves_like 'unanswer?', false, 1
      it_behaves_like 'unanswer?', true, 2
      it_behaves_like 'unanswer?', true, 3
    end

    context '全て解答済み' do
      include_context 'answered all'
      it_behaves_like 'unanswer?', false, 1
      it_behaves_like 'unanswer?', false, 2
      it_behaves_like 'unanswer?', false, 3
    end
  end

  describe '#judge_answer' do
    subject { session.judge_answer(1) }

    context '未解答の駅IDを指定する' do
      it { is_expected.to be_truthy }
    end
    context '解答済みの駅IDを指定する' do
      include_context 'answered one'
      it { is_expected.to be_falsey }
    end
  end

  describe '#answered_all?' do
    subject { session.answered_all? }

    context '初期状態' do
      it { is_expected.to be_falsey }
    end

    context '一件解答済み' do
      include_context 'answered one'
      it { is_expected.to be_falsey }
    end

    context '全て解答済み' do
      include_context 'answered all'
      it { is_expected.to be_truthy }
    end
  end

  shared_examples 'permit_station' do |permit_station_names|
    it { expect(permit_station_names.include?(result)).to be_truthy }
  end

  describe '#answer_by_npc' do
    let(:result) { session.answer_by_npc }
    context '初期状態' do
      it_behaves_like 'permit_station', %w[東京 神田 上野]
    end

    context '一件解答済み' do
      include_context 'answered one'
      it_behaves_like 'permit_station', %w[神田 上野]
    end

    context '二件解答済み' do
      include_context 'answered two'
      it_behaves_like 'permit_station', %w[上野]
    end

    context '全て解答済み' do
      include_context 'answered all'
      it { expect(result).to be_falsey }
    end
  end

  describe '#answer' do
    subject { session.__send__ :answer, 1 }
    it { is_expected.to be_truthy }
  end

  describe '#answer_bit' do
    subject { session.__send__ :answer_bit, false }
    it { is_expected.to eq '0' }
  end
end
