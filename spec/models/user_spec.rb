require 'rails_helper'

RSpec.describe User, type: :model do
  it 'factorybotが有効かどうか' do
    user = build(:user)
    expect(user).to be_valid
  end
end
