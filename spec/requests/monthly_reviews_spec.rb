require 'rails_helper'

RSpec.describe 'MonthlyReviews', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET /monthly_reviews' do
    it '200 OK が返り、過去12か月分の月初日が表示されること' do
      get monthly_reviews_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include Date.today.prev_month(1).strftime('%Y-%m')
      expect(response.body).to include Date.today.prev_month(12).strftime('%Y-%m')
    end
  end

  describe 'GET /monthly_reviews/:month' do
    context '指定月に日記がある場合' do
      let!(:diary) do
        create(:diary, :with_contents,
               user: user,
               posted_date: '2025-11-15',
               body_texts: [ 'テスト' ])
      end

      let!(:diary2) do
        create(:diary, :with_contents,
              user: user,
              posted_date: '2025-11-20',
              happiness_count: 3,
              body_texts: [ '一番幸せのかけらが多い日記', 'テスト２', 'テスト３' ])
      end

      it '200 OK が返り、集計情報が表示されること' do
        get monthly_review_path(month: '2025-11')
        expect(response).to have_http_status(:ok)
        expect(response.body).to include '4' # 合計値
        expect(response.body).to include '2' # 平均値
        expect(response.body).to include '3' # 最大値
        expect(response.body).to include '一番幸せのかけらが多い日記', 'テスト２', 'テスト３' # 最大値の日記本文
      end
    end

    context '指定月に日記がない場合' do
      it '200 OK が返り、monthly_review が nil であること' do
        get monthly_review_path(month: '2025-11')
        expect(response).to have_http_status(:ok)
        expect(response.body).to include 'この月の記録はありません'
      end
    end
  end
end
