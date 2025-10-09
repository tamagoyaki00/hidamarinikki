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

      it '名前編集ページに直接アクセスするとrootページにリダイレクトされる' do
      visit edit_user_registration_path
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

  describe 'ユーザー編集に関すること' do
    let(:user) { create(:user) }

    context 'ページ遷移' do
      before { login_as(user) }

      it 'ユーザー詳細ページから編集ページへ正しく遷移できること' do
        visit user_path(user)
        click_link '編集'
        expect(page).to have_current_path edit_user_registration_path
      end
    end

    context '編集フォームの初期値' do
    before { login_as(user) }
      it '編集フォームに現在の名前、自己紹介が表示されていること' do
        visit edit_user_registration_path
        expect(find_field('user_name').value).to eq(user.name)
        expect(find_field('user_introduction').value).to eq(user.introduction)
      end
    end

    context '名前編集' do
      before { login_as(user) }
      it '名前を正常に編集できる' do
        visit user_path(user)
        click_link '編集'

        fill_in 'ユーザー名', with: '新しい名前'
        click_button '更新'

        expect(page).to have_content('アカウント情報を変更しました')
        expect(page).to have_content('新しい名前')
        expect(page).to have_current_path user_path(user)
      end

      it '空の名前では編集できない' do
        visit user_path(user)
        click_link '編集'
        fill_in 'ユーザー名', with: ''
        click_button '更新'

        expect(page).to have_content("ユーザー名を入力してください")
        expect(page).to have_current_path edit_user_registration_path
      end
    end

    context '自己紹介文の編集' do
      before { login_as(user) }
      it '自己紹介文を正常に編集できる' do
        visit user_path(user)
        click_link '編集'
        fill_in '自己紹介', with: '自己紹介テスト'
        click_button '更新'

        expect(page).to have_content('アカウント情報を変更しました')
        expect(page).to have_content('自己紹介テスト')
        expect(page).to have_current_path user_path(user)
      end

      it '自己紹介文が201文字以上の場合、無効になる' do
        visit user_path(user)
        click_link '編集'
        fill_in '自己紹介', with: 'あ' * 201
        click_button '更新'

        expect(page).to have_content('自己紹介は200文字以内で入力してください')
      end
    end

    context 'アバター画像' do
      before { login_as(user) }

      it 'アバター画像を正常に編集できる' do
        visit user_path(user)
        click_link '編集'

        attach_file 'user_avatar', Rails.root.join('spec/fixtures/files/test.jpg')
        click_button '更新'

        expect(page).to have_content('アカウント情報を変更しました')
        expect(page).to have_current_path user_path(user)
        expect(page).to have_selector("img[src*='test.jpg']")
      end
    end
  end
end
