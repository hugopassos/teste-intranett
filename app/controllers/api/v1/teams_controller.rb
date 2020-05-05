class Api::V1::TeamsController < ApplicationController
  before_action :manager?

  def new
    json_response 'Criar nova equipe', true, {}, :ok
  end

  def create
    team = Team.new(team_params)
    if team.save
      # Ao criar uma equipe, o gestor tambem passa a fazer parte dela
      current_user.update_attributes(team_id: team.id)
      json_response 'Equipe criada com sucesso', true, { team: team }, :ok
    else
      json_response 'Algo deu errado', false, {}, :unprocessable_entity
    end
  end

  def edit
    users_not_in_team = User
      .where.not(team_id: params[:id])
      .where.not(team_id: nil)
      .or(User.where(team_id: nil))
      .map(&:serialize)

    users_in_team = User.where(team_id: params[:id]).map(&:serialize)

    team = Team.find_by(id: params[:id])
    if team
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
      json_response 'Equipe não encontrada', false, {}, :not_found
    end
  end

  def update
    team = Team.find_by(id: params[:id])
    # Gestores podem alterar apenas equipes que tenham criado
    if current_user.team_id == team.id
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
      json_response 'Algo deu errado', false, {}, :unprocessable_entity
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

    return if current_user.role_id == gestor_id

    json_response 'Somente gestores podem criar/alterar equipes', false, {}, :unauthorized
  end
end
