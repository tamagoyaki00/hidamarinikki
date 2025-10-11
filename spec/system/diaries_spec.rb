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

  describe '日記作成機能' do
    before do
      visit new_diary_path
    end

    it '日記作成フォームの初期値が正しく表示されていること' do
      expect(page).to have_content '今日の一日を振り返ってみよう'
      expect(page).to have_content(Date.current.to_s)
      expect(page).to have_css('#items-container textarea', count: 5)
      expect(page).to have_checked_field('diary_form_status_is_public', visible: false)
      expect(page).to have_field('diary_form[tag_names]', with: '')
      expect(page).to have_field('diary_form[photos][]', type: 'file')
    end


    context '入力内容が正しい場合' do
      it 'ホームページにリダイレクトされること' do
        fill_in 'item_1', with: '楽しかったこと1'
        fill_in 'item_2', with: '楽しかったこと2'
        fill_in 'item_3', with: '楽しかったこと3'
        fill_in 'diary_form[tag_names]', with: '日常, 幸せ'
        click_button '投稿する'
        expect(page).to have_content '日記を投稿しました'
        expect(page).to have_current_path home_path
      end
    end

    context '入力内容が正しくない場合' do
      it '日記内容を空のまま登録しようとすると、エラーメッセージが表示されること' do
        invalid_form = build(:diary_form, happiness_items: [ '' ])
        expect(invalid_form).to be_invalid
        expect(invalid_form.errors.full_messages).to include('少なくとも1つの幸せを入力してください')
        expect(page).to have_current_path new_diary_path
      end

      it 'タグを11個以上つけようとすると、エラーメッセージが表示されること' do
        invalid_form = build(:diary_form, :with_11tags)
        expect(invalid_form).to be_invalid
        expect(invalid_form.errors.full_messages).to include('タグは10個以内にしてください')
        expect(page).to have_current_path new_diary_path
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
