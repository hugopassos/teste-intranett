require 'rails_helper'

RSpec.describe User, type: :model do
  it { should belong_to(:role) }
  it { should belong_to(:team) }

  let(:user) { User.new(email: 'teste@mail.com', password: '123456', role_id: '') }

  describe '#email' do
    it 'should not allow invalid format' do
      user.email = 'invalid'
      user.valid?
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'should be present' do
      user.email = ''
      user.valid?
      expect(user.errors[:email]).to include('can\'t be blank')
    end
  end

  describe '#password' do
    it 'should be present' do
      user.password = ''
      user.valid?
      expect(user.errors[:password]).to include('can\'t be blank')
    end

    it 'should have at least 6 characters' do
      user.password = 'a' * 5
      user.valid?
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end
  end

  describe '#role_id' do
    it 'should be present' do
      user.save
      user.valid?
      expect(user.errors[:role_id]).to include('can\'t be blank')
    end
  end
end
