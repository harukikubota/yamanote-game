require 'rails_helper'

RSpec.describe Station, type: :model do
  let!(:find) { Station.method(:find) }
  let(:tokyo) { find.call(1) }
  let(:kanda) { find.call(2) }
  let(:ueno) { find.call(3) }

  describe 'テストデータが正統であること' do
    it '3件のみであること' do
      expect(Station.count).to eq 3
    end

    it '名前が正しいこと' do
      expect(tokyo.name).to eq '東京'
      expect(kanda.name).to eq '神田'
      expect(ueno.name).to  eq '上野'
    end
  end
end
