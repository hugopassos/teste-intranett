require 'rails_helper'

RSpec.describe Api::V1::TeamsController, type: :request do
  before(:each) do
    role_colab = Role.create(name: 'Colaborador')
    role_gestor = Role.create(name: 'Gestor')
    @colaborador = User.create(email: 'colaborador@mail.com', password: '123456', role_id: role_colab.id)
    @gestor = User.create(email: 'gestor@mail.com', password: '123456', role_id: role_gestor.id)
    @team = Team.create(name: 'Equipe 1')
    @gestor_equipe = User.create(email: 'gestor_equipe@mail.com',
                                 password: '123456',
                                 role_id: role_gestor.id,
                                 team_id: @team.id)
    @headers = { 'Accept': 'application/json',
                 'Content-Type': 'application/json',
                 'AUTH-TOKEN': @gestor.authentication_token }
  end

  describe '#new' do
    it 'allows managers to create a new team' do
      get '/api/v1/teams/new', headers: @headers
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response['message']).to eq('Criar nova equipe')
    end

    it 'doesn\'t allow colaborators to create a new team' do
      @headers['AUTH-TOKEN'] = @colaborador.authentication_token
      get '/api/v1/teams/new', headers: @headers
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:forbidden)
      expect(json_response['message']).to eq('Somente gestores podem criar/alterar equipes')
    end
  end

  describe '#create' do
    it 'allows managers to save a new team' do
      params = { team: { name: 'Equipe 2' } }
      post '/api/v1/teams', params: params.to_json, headers: @headers
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response['message']).to eq('Equipe criada com sucesso')
      expect(json_response['data']['team']['name']).to eq('Equipe 2')
      gestor = User.find_by(id: @gestor.id)
      expect(gestor.team_id).to eq(json_response['data']['team']['id'])
    end

    it 'doesn\'t allow managers to create a second team' do
      @headers['AUTH-TOKEN'] = @gestor_equipe.authentication_token
      params = { team: { name: 'Equipe 2' } }
      post '/api/v1/teams', params: params.to_json, headers: @headers
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:unauthorized)
      expect(json_response['message']).to eq('Algo deu errado')
    end
  end

  describe '#edit' do
    it 'allows managers to edit his own team' do
      @headers['AUTH-TOKEN'] = @gestor_equipe.authentication_token
      get "/api/v1/teams/#{@team.id}/edit", headers: @headers
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response['message']).to eq('Editar equipe')
    end

    it 'does not allow managers to edit teams they do not own' do
      @headers['AUTH-TOKEN'] = @gestor.authentication_token
      get "/api/v1/teams/#{@team.id}/edit", headers: @headers
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:unauthorized)
      expect(json_response['message']).to eq('Não possui permissão para editar a equipe')
    end
  end

  # Teste simples validando apenas autorizacao
  describe '#update' do
    it 'allows managers to update his own team' do
      @headers['AUTH-TOKEN'] = @gestor_equipe.authentication_token
      params = { team: { users_in_team: {}, users_not_in_team: {} } }
      patch "/api/v1/teams/#{@team.id}", params: params.to_json, headers: @headers
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response['message']).to eq('Equipe atualizada com sucesso')
    end

    it 'does not allow managers to update teams they do not own' do
      @headers['AUTH-TOKEN'] = @gestor.authentication_token
      params = { team: { users_in_team: {}, users_not_in_team: {} } }
      patch "/api/v1/teams/#{@team.id}", params: params.to_json, headers: @headers
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:unauthorized)
      expect(json_response['message']).to eq('Não possui permissão para editar a equipe')
    end
  end
end
