class Api::V1::SessionsController < Devise::SessionsController
  before_action :load_user, only: :create
  before_action :valid_token, only: :destroy
  skip_before_action :verify_signed_out_user, only: :destroy
  skip_before_action :authenticate

  def create
    if @user.valid_password?(user_params[:password])
      sign_in(:user, @user)
      json_response 'Bem vindo!', true, { user: @user }, :ok
    else
      json_response 'Email ou senha inválidos', false, {}, :unauthorized
    end
  end

  def destroy
    sign_out @user
    @user.generate_new_authentication_token
    json_response 'Logout realizado com sucesso', true, {}, :ok
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

  def load_user
    if (@user = User.find_for_database_authentication(email: user_params[:email]))
      @user
    else
      json_response 'Email ou senha inválidos', false, {}, :unauthorized
    end
  end

  def valid_token
    if (@user = User.find_by(authentication_token: request.headers['AUTH-TOKEN']))
      @user
    else
      json_response 'Token de acesso inválido ou não informado', false, {}, :unauthorized
    end
  end
end
