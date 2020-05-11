class User < ApplicationRecord
  acts_as_token_authenticatable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :role_id, presence: true

  belongs_to :role
  belongs_to :team, optional: true
  has_many :tasks
  scope :colaborators, -> { where(role: colaborator_role) }

  def generate_new_authentication_token
    token = User.generate_unique_secure_token
    update_attributes authentication_token: token
  end

  def serialize
    UserSerializer.new(self).to_hash
  end
end
