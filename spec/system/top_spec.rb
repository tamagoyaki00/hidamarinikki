require 'rails_helper'

RSpec.describe "トップページ", type: :system do
  it "タイトルに「ひだまり日記」が表示される" do
    visit unauthenticated_root_path
    expect(page).to have_content("ひだまり日記")
  end
end
