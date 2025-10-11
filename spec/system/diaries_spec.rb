require 'rails_helper'

RSpec.describe 'Diaries', type: :system do
  let(:user) { create(:user) }
  let(:diary) { create(:diary) }

  describe '未ログインの場合' do
    it '編集画面にアクセスできずログイン画面にリダイレクトされること' do
      visit edit_diary_path(diary)
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content('ログインもしくはアカウント登録してください')
    end
  end

  describe 'ログイン済みの場合' do
    before do
      login_as(user)
    end

    it 'ログイン後のホーム画面で日記を書くが表示されていること（ダミーテスト）' do
      visit authenticated_root_path
      expect(page).to have_content '日記を書く'
    end


    describe 'ページ遷移が正常にできること' do
      it 'ホームページから日記作成画面にページ遷移ができること' do
        visit home_path
        click_on '日記を書く'
        expect(page).to have_current_path new_diary_path
        expect(page).to have_content '今日の一日を振り返ってみよう'
      end

      it 'マイ日記から日記作成画面にページ遷移ができること' do
        visit my_diaries_path
        find('a.btn.btn-primary.btn-circle').click
        expect(page).to have_current_path new_diary_path
        expect(page).to have_content '今日の一日を振り返ってみよう'
      end

      it 'みんなの日記から日記作成画面にページ遷移ができること' do
        visit public_diaries_path
        find('a.btn.btn-primary.btn-circle').click
        expect(page).to have_current_path new_diary_path
        expect(page).to have_content '今日の一日を振り返ってみよう'
      end

      context '本日の日記が既に存在する場合' do
        it '新規作成ボタンを押すと編集画面に遷移すること' do
          visit home_path
          click_on '日記を書く'
          expect(page).to have_content '日記の編集'
        end
      end
    end
  end

  describe '日記一覧に関すること' do
    let(:other_user) { create(:user) }

    let!(:my_public_diary) do
      create(:diary, :with_content,
            user: user,
            body_text: 'マイ公開日記')
    end

    let!(:my_private_diary) do
      create(:diary, :private, :with_content,
            user: user,
            posted_date: 2.days.ago,
            body_text: 'マイ非公開日記')
    end

    let!(:other_public_diary) do
      create(:diary, :with_content,
            user: other_user,
            posted_date: Time.current,
            body_text: '他人の公開日記')
    end


    it 'マイ日記ページには、自身が投稿した日記の一覧がすべて表示されること' do
      visit my_diaries_path
      expect(page).to have_content 'マイ公開日記'
      expect(page).to have_content 'マイ非公開日記'
    end

    it 'みんなの日記ページには、公開された日記がすべて表示されること' do
      visit public_diaries_path
      expect(page).to have_content 'マイ公開日記'
      expect(page).to have_content '他人の公開日記'
    end

    it 'みんなの日記ページには、非公開の日記は表示されないこと' do
      visit public_diaries_path
      expect(page).not_to have_content 'マイ非公開日記'
    end

    it '日記の内容には、ユーザーアバター・ユーザー名・日付・本文・ステータス・タグが表示されていること' do
      visit public_diaries_path
      within first('.diary-card') do
        expect(page).to have_selector('.user-avatar') # アバター
        expect(page).to have_content other_user.name     # ユーザー名
        expect(page).to have_content other_public_diary.posted_date.strftime('%Y年%m月%d日') # 日付
        expect(page).to have_content '他人の公開日記'   # 本文
        expect(page).to have_content '公開'             # ステータス表示
        other_public_diary.tags.each do |tag|
          expect(page).to have_content tag.name
        end
      end
    end

    it '日記は新しい順に並んでいること' do
      visit public_diaries_path
      diary_dates = all('.diary-card .diary-date').map(&:text)
      expect(diary_dates).to eq [
        other_public_diary.posted_date.strftime('%Y年%m月%d日'),
        my_public_diary.posted_date.strftime('%Y年%m月%d日')
      ]
    end

    it '写真をクリックするとモーダルで拡大表示されること' do
      diary_with_photo = create(:diary, :with_content, :with_photo, user: user, body_text: '写真付き日記')
      visit my_diaries_path
      find('.diary-photo').click
      expect(page).to have_selector('.modal', visible: true)
      expect(page).to have_selector('.modal img')
    end
  end
end
