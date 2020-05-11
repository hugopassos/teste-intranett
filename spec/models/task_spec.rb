require 'rails_helper'

RSpec.describe Role, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:status) }

  let(:task) { User.new(title: 'Task 1', start_time: Time.now) }

  describe '#title' do
    it 'should be present' do
      task.title = ''
      task.valid?
      expect(user.errors[:title]).to include('can\'t be blank')
    end
  end

  describe '#start_time' do
    it 'should be present' do
      task.password = ''
      task.valid?
      expect(user.errors[:title]).to include('can\'t be blank')
    end
  end
end
