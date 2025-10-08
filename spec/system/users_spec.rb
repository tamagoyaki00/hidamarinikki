require 'rails_helper'

RSpec.describe "Users", type: :system do
  describe '新規登録' do
    context '有効な入力した場合' do
      it '新規登録が成功すること' do
        visit new_user_registration_path
        fill_in 'ユーザー名', with: 'テストユーザー'
        fill_in 'メールアドレス', with: 'test@example.com'
        fill_in 'パスワード', with: 'password'
        fill_in 'パスワード（確認用）', with: 'password'
        click_button '登録'

        expect(page).to have_content 'アカウント登録が完了しました'
        expect(User.count).to eq(1)
      end
    end

    context '必須項目が未入力の場合' do
      it 'エラーになり、新規登録が失敗すること' do
        visit new_user_registration_path
        fill_in 'ユーザー名', with: ''
        fill_in 'メールアドレス', with: ''
        fill_in 'パスワード', with: ''
        click_button '登録'

        expect(page).to have_content 'ユーザー名を入力してください'
        expect(page).to have_content 'メールアドレスを入力してください'
        expect(page).to have_content 'パスワードを入力してください'
      end
    end
  end

  describe 'ログインに関すること' do
    let!(:user) { create(:user) }

    context '未ログインのとき' do
      it '認証必須ページにアクセスできない' do
        visit home_path
        expect(page).to have_current_path new_user_session_path
        expect(page).to have_content 'ログインもしくはアカウント登録してください'
      end
    end

    context 'ログイン時' do
      it '正しい情報でログインできる' do
        visit new_user_session_path
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: 'password'
        click_button 'ログイン'
        expect(page).to have_content 'ログインしました'
        expect(page).to have_current_path authenticated_root_path
      end

      it '誤った情報ではログインできない' do
        visit new_user_session_path
        fill_in 'メールアドレス', with: 'wrong@example.com'
        fill_in 'パスワード', with: 'wrongpass'
        click_button 'ログイン'
        expect(page).to have_content 'メールアドレスまたはパスワードが違います'
      end
    end

    context 'ログイン後' do
      before { login_as(user) }

      it 'ブラウザを閉じてもログイン状態が維持される' do
        Capybara.reset_sessions! # ブラウザを閉じた想定
        visit authenticated_root_path
        expect(page).to have_current_path authenticated_root_path
      end

      it 'ログアウトができること' do
        click_button '設定'
        click_link 'ログアウト'
        expect(page).to have_content 'ログアウトしました'
      end
    end

    context 'ログアウト後' do
      it 'ログアウト後は認証必須ページにアクセスできない' do
        login_as(user)
        click_button '設定'
        click_link 'ログアウト'
        visit authenticated_root_path
        expect(page).to have_current_path unauthenticated_root_path
      end
    end
  end
end
