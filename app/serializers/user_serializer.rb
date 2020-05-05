class UserSerializer < ActiveModel::Serializer
  attribute :id
  attribute :email
  attribute :role_name

  def role_name
    object.role.name
  end
end
