class Api::V1::RegistrationsController < Devise::RegistrationsController
  def create
    @user = User.new(user_params)
    if @user.save
      json_response 'Conta criada com sucesso', true, { user: @user }, :ok
    else
      json_response 'Algo deu errado', false, {}, :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role_id)
  end
end
