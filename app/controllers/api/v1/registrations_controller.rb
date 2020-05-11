class Api::V1::RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate

  def create
    role_id = Role.find_by(name: 'Colaborador').id
    user_with_role = user_params.merge({ role_id: role_id })
    user = User.new(user_with_role)
    if user.save
      json_response 'Conta criada com sucesso', true, { user: user }, :ok
    else
      json_response 'Algo deu errado', false, {}, :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
