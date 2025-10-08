require 'rails_helper'

RSpec.describe "Users", type: :system do
  describe '新規登録' do
    context '有効な入力した場合'
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

    context '必須項目が未入力の場合'
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