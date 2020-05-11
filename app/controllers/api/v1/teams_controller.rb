class Api::V1::TeamsController < ApplicationController
  before_action :manager?

  def create
    team = Team.new(team_params)
    # Neste cenario, assume-se que o gestor nao podera criar mais de uma equipe
    if @current_user.team_id.nil? && team.save
      @current_user.update_attributes(team_id: team.id)
      json_response 'Equipe criada com sucesso', true, { team: team }, :ok
    else
      json_response 'Algo deu errado', false, {}, :unauthorized
    end
  end

  def show
    team = Team.find_by(id: params[:id])
    # Gestores podem ver apenas equipes que tenham criado
    if team && @current_user.team_id == team.id

      # Neste exemplo, seriam retornados usuarios pertencentes a equipe e tambem usuarios sem equipe
      # Usuarios na equipe teriam ao lado o botao 'remover', e usuarios sem equipe 'adicionar'
      users = load_colaborators(team.id)

      json_response 'Detalhes da equipe', true, { team: { users: users } }, :ok
    else
      json_response 'Algo deu errado', false, {}, :unauthorized
    end
  end

  def update
    team = Team.find_by(id: params[:id])
    if team && @current_user.team_id == team.id
      team_value = team_params[:action] == 'add' ? Team.find_by(id: params[:id]).id : nil
      user = User.find_by(id: team_params[:user_id])
      # Validacao adicional para que equipes nao tenham dois gestores
      user.update_attributes(team_id: team_value) unless user_is_manager?(user)

      users = load_colaborators(team.id)

      json_response('Equipe atualizada', true, { team: { users: users } }, :ok)
    else
      json_response 'Algo deu errado', false, {}, :unauthorized
    end
  end

  private

  def team_params
    params.require(:team).permit(:name, :user_id, :action)
  end

  # Somente gestores podem criar/alterar equipes
  def manager?
    return if user_is_manager?(@current_user)

    json_response 'Apenas gestores podem realizar esta operação', false, {}, :forbidden
  end

  def load_colaborators(team_id)
    User.where.not(role_id: Role.where(name: 'Gestor'))
      .where(team_id: team_id)
      .or(User.where(team_id: nil))
  end
end
