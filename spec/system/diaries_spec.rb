require 'rails_helper'

RSpec.describe 'Diaries', type: :system do

  let(:user) { create(:user) }

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
        invalid_form = build(:diary_form, happiness_items: [''])
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
end