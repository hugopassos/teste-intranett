require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :request do
  before(:each) do
    role = Role.create(name: 'Colaborador')
    @user = User.create(email: 'teste@teste.com', password: '123456', role_id: role.id)
  end

  describe '#create' do
    it 'returns json data when user logs in' do
      params = { user: { email: @user.email, password: @user.password } }
      post '/api/v1/login', params: params
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to eq({ 'user' => @user.as_json })
      expect(response).to have_http_status(:ok)
    end

    it 'doesn\'t login a user with non-existing email' do
      params = { user: { email: 'anything@mail.com', password: 'anything' } }
      post '/api/v1/login', params: params
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to eq({})
      expect(response).to have_http_status(:unauthorized)
    end

    it 'doesn\'t login a user with incorrect password' do
      params = { user: { email: @user.email, password: 'anything' } }
      post '/api/v1/login', params: params
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to eq({})
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe '#destroy' do
    it 'logs the user out' do
      headers = { 'Accept': 'application/json',
                  'Content-type': 'application/json',
                  'AUTH-TOKEN': @user.authentication_token }
      delete '/api/v1/logout', headers: headers
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to eq({})
      expect(json_response['message']).to eq('Logout realizado com sucesso')
    end

    it 'doesn\'t allow the operation without a valid token' do
      headers = { 'Accept': 'application/json',
                  'Content-type': 'application/json',
                  'AUTH-TOKEN': 'anything' }
      delete '/api/v1/logout', headers: headers
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:unauthorized)
      expect(json_response['message']).to eq('Token de acesso inválido ou não informado')
    end
  end
end
