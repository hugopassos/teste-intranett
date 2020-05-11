require 'rails_helper'

RSpec.describe Api::V1::TasksController, type: :request do
  before(:each) do
    create(:status)
    role_gestor = create(:role)
    role_colab = create(:role, name: 'Colaborador')
    team = create(:team, name: 'Team 1')
    @gestor = create(:user, role_id: role_gestor.id, team_id: team.id)
    @colaborador = create(:user, email: 'colaborador@mail.com', role_id: role_colab.id, team_id: team.id)
    @task = create(:task, user_id: @gestor.id)
    @task2 = create(:task, title: 'Task 2', user_id: @colaborador.id)

    @headers = { 'Accept': 'application/json',
                 'Content-Type': 'application/json',
                 'AUTH-TOKEN': @gestor.authentication_token }
  end

  describe '#index' do
    it 'allows colaborators to see only their own tasks' do
      @headers['AUTH-TOKEN'] = @colaborador.authentication_token
      get '/api/v1/tasks/', headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['data']['tasks'][0]).to include("title" => "Task 2")
      expect(json_response['data']['tasks'][1]).to eq(nil)
    end

    it 'allows managers to see tasks from all members of his team' do
      get '/api/v1/tasks/', headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['data']['tasks'][0]).to include("title" => "Task 1")
      expect(json_response['data']['tasks'][1]).to include("title" => "Task 2")
    end
  end

  describe '#create' do
    it 'allows users to create a task' do
      params = { title: 'Tarefa 1', user_id: @colaborador.id, status_id: 1 }
      post '/api/v1/tasks/', params: params.to_json, headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Tarefa criada com sucesso')
      params[:user_id] = @gestor.id
      post '/api/v1/tasks/', params: params.to_json, headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Tarefa criada com sucesso')
    end
  end

  describe '#show' do
    it 'allows users to see details of their tasks' do
      get "/api/v1/tasks/#{@task.id}", headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Detalhes da tarefa')
    end

    it 'doesn\'t allow users to see details of other users tasks' do
      get "/api/v1/tasks/#{@task2.id}", headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Algo deu errado')
    end
  end

  describe '#update' do
    it 'allows users to cancel their tasks' do
      create(:status, name: 'Cancelado')
      status_id = Status.find_by(name: 'Cancelado').id
      params = { task: { notes: 'Cancelar task', status_name: 'Cancelado' } }
      patch "/api/v1/tasks/#{@task.id}", params: params.to_json, headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['data']['task']['status_id']).to eq(status_id)
      expect(json_response['data']['task']['end_time']).to_not eq(nil)
    end

    it 'allows users to finish their tasks' do
      create(:status, name: 'Finalizado')
      status_id = Status.find_by(name: 'Finalizado').id
      params = { task: { status_name: 'Finalizado' } }
      patch "/api/v1/tasks/#{@task.id}", params: params.to_json, headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['data']['task']['status_id']).to eq(status_id)
      expect(json_response['data']['task']['end_time']).to_not eq(nil)
    end

    it 'allows users to edit their tasks' do
      status_id = Status.find_by(name: 'Em andamento').id
      params = { task: { name: 'New name', status_name: 'Em andamento' } }
      patch "/api/v1/tasks/#{@task.id}", params: params.to_json, headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['data']['task']['status_id']).to eq(status_id)
      # A task foi alterada mas nao finalizada ou cancelada, entao nao existe end_time
      expect(json_response['data']['task']['end_time']).to eq(nil)
    end

    it 'does not allow users to edit other users tasks' do
      params = { task: { name: 'New name', status_name: 'Em andamento' } }
      patch "/api/v1/tasks/#{@task2.id}", params: params.to_json, headers: @headers
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Não foi possível salvar')
    end
  end
end
