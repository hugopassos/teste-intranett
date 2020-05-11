require 'rails_helper'

RSpec.describe Api::V1::TeamsController, type: :request do
  before(:each) do
    create(:status)
    role_gestor = create(:role)
    role_colab = create(:role, name: 'Colaborador')
    @team = create(:team, name: 'Team 1')
    @gestor = create(:user, role_id: role_gestor.id)
    @gestor_equipe = create(:user, email: 'gestor2@mail.com', role_id: role_gestor.id, team_id: @team.id)
    @colaborador = create(:user, email: 'colaborador@mail.com', role_id: role_colab.id, team_id: @team.id)

    @headers = { 'Accept': 'application/json',
                 'Content-Type': 'application/json',
                 'AUTH-TOKEN': @gestor.authentication_token }
  end

  describe '#create' do
    it 'allows managers to save a new team' do
      params = { team: { name: 'Equipe 2' } }
      post '/api/v1/teams', params: params.to_json, headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Equipe criada com sucesso')
      expect(json_response['data']['team']['name']).to eq('Equipe 2')
    end

    it 'doesn\'t allow managers to create a second team' do
      @headers['AUTH-TOKEN'] = @gestor_equipe.authentication_token
      params = { team: { name: 'Equipe 2' } }
      post '/api/v1/teams', params: params.to_json, headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Algo deu errado')
    end

    it 'doesn\'t allow colaborators to create a new team' do
      @headers['AUTH-TOKEN'] = @colaborador.authentication_token
      params = { team: { name: 'Equipe 2' } }
      post '/api/v1/teams', params: params.to_json, headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Apenas gestores podem realizar esta operação')
    end
  end

  describe '#show' do
    it 'allows managers to see/edit their own team' do
      @headers['AUTH-TOKEN'] = @gestor_equipe.authentication_token
      get "/api/v1/teams/#{@team.id}", headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Detalhes da equipe')
    end

    it 'does not allow managers to see/edit teams they do not own' do
      @headers['AUTH-TOKEN'] = @gestor.authentication_token
      get "/api/v1/teams/#{@team.id}", headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Algo deu errado')
    end
  end

  # Teste simples validando apenas autorizacao
  describe '#update' do
    it 'allows managers to update his own team' do
      @headers['AUTH-TOKEN'] = @gestor_equipe.authentication_token
      params = { team: { user_id: @colaborador.id } }
      patch "/api/v1/teams/#{@team.id}", params: params.to_json, headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Equipe atualizada')
    end

    it 'does not allow managers to update teams they do not own' do
      @headers['AUTH-TOKEN'] = @gestor.authentication_token
      params = { team: { users_in_team: {}, users_not_in_team: {} } }
      patch "/api/v1/teams/#{@team.id}", params: params.to_json, headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Algo deu errado')
    end
  end
end
