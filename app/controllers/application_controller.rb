class ApplicationController < ActionController::API
  include Response

  before_action :authenticate

  protected

  def authenticate
    @current_user = User.find_by_authentication_token(request.headers['AUTH-TOKEN'])

    json_response 'Token de acesso inválido ou não informado', false, {}, :unauthorized if @current_user.nil?
  end
end
