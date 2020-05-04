require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    role = Role.create(name: 'Colaborador')
    @user = User.create(email: 'teste@teste.com', password: '123456', role_id: role.id)
  end

  describe '#create' do
    it 'should return json data when user logs in' do
      params = { user: { email: @user.email, password: @user.password } }
      post :create, params: params
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to eq({ 'user' => @user.as_json })
      expect(response).to have_http_status(:ok)
    end

    it 'should not login a user with non-existing email' do
      params = { user: { email: 'anything@mail.com', password: 'anything' } }
      post :create, params: params
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to eq({})
      expect(response).to have_http_status(:unauthorized)
    end

    it 'should not login a user with incorrect password' do
      params = { user: { email: @user.email, password: 'anything' } }
      post :create, params: params
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to eq({})
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe '#destroy' do
    it 'should logout the user' do
      params = { user: { email: @user.email, password: @user.password } }
      headers = { 'AUTH-TOKEN' => @user.authentication_token }
      post :create, params: params
      request.headers.merge! headers
      delete :destroy
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to eq({})
      expect(json_response['message']).to eq('Logout realizado com sucesso')
    end

    it 'should return failure message when authentication token doesn\'t exist' do
      params = { user: { email: @user.email, password: @user.password } }
      headers = { 'AUTH-TOKEN' => 'anything' }
      post :create, params: params
      request.headers.merge! headers
      delete :destroy
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:expectation_failed)
      expect(json_response['message']).to eq('Algo deu errado')
    end
  end
end
