require 'rails_helper'

RSpec.describe Api::V1::TeamsController, type: :controller do
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    role_colab = Role.create(name: 'Colaborador')
    role_gestor = Role.create(name: 'Gestor')
    @colaborador = User.create(email: 'colaborador@mail.com', password: '123456', role_id: role_colab.id)
    @gestor = User.create(email: 'gestor@mail.com', password: '123456', role_id: role_gestor.id)
  end

  describe '#new' do
    it 'should allow a manager to create a new team' do
      params = { user: { email: @gestor.email, password: @gestor.password } }
      post :create, params: { use_route: 'api/v1/login', params: params }
      get :new
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response['message']).to eq('Criar nova equipe')
    end
  end
end
