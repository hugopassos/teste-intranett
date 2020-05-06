class Api::V1::TeamsController < ApplicationController
  before_action :manager?

  def new
    json_response 'Criar nova equipe', true, {}, :ok
  end

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

  def edit
    team = Team.find_by(id: params[:id])
    # Gestores podem alterar apenas equipes que tenham criado
    if team && @current_user.team_id == team.id
      users_in_team = load_users_in_team(params[:id])
      users_not_in_team = load_users_not_in_team(params[:id])
      json_response('Editar equipe',
                    true,
                    {
                      team: {
                        users_in_team: users_in_team,
                        users_not_in_team: users_not_in_team
                      }
                    },
                    :ok)
    else
      json_response 'Não possui permissão para editar a equipe', false, {}, :unauthorized
    end
  end

  def update
    team = Team.find_by(id: params[:id])
    if team && @current_user.team_id == team.id
      users_not_in_team = team_params[:users_not_in_team]
      users_in_team = team_params[:users_in_team]

      users_in_team.each do |user|
        u = User.find_by(id: user[:id])
        # Nao e permitido adicionar outro gestor a equipe - "Equipes contem 1 Gestor e N Colaboradores"
        u.update_attributes(team_id: params[:id]) unless user[:role_name] == 'Gestor'
      end

      users_not_in_team.each do |user|
        u = User.find_by(id: user[:id])
        # Nao e permitido que o gestor remova a si proprio da equipe
        u.update_attributes(team_id: nil) unless user[:role_name] == 'Gestor'
      end

      json_response('Equipe atualizada com sucesso',
                    true,
                    {
                      team: {
                        users_in_team: users_in_team,
                        users_not_in_team: users_not_in_team
                      }
                    },
                    :ok)
    else
      json_response 'Não possui permissão para editar a equipe', false, {}, :unauthorized
    end
  end

  private

  def team_params
    params.require(:team).permit(:name,
                                 users_in_team: %i[id email role_name],
                                 users_not_in_team: %i[id email role_name])
  end

  # Somente gestores podem criar/alterar equipes
  def manager?
    gestor_id = Role.where(name: 'Gestor').first.id

    return if @current_user.role_id == gestor_id

    json_response 'Somente gestores podem criar/alterar equipes', false, {}, :forbidden
  end

  def load_users_in_team(team_id)
    User.where(team_id: team_id).map(&:serialize)
  end

  def load_users_not_in_team(team_id)
    User.where(team_id: nil).map(&:serialize)
  end
end
