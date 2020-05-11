class Task < ApplicationRecord
  belongs_to :user
  belongs_to :status
  validates_presence_of :title, :start_time, :status

  after_initialize :init

  def self.load_team_tasks(user)
    Task.where(user_id: User.where(team_id: user.team_id)).order(:status_id)
  end

  def self.load_user_tasks(user)
    Task.where(user_id: user.id).order(:status_id)
  end

  def serialize
    TaskSerializer.new(self).to_hash
  end

  private

  def init
    self.start_time = Time.now
    self.status_id = Status.find_by(name: 'Em andamento').id
  end
end
