class Api::V1::TasksController < ApplicationController
  def index
    # Gerentes podem ver as tarefas da equipe
    if user_is_manager?(@current_user)
      tasks = Task.load_team_tasks(@current_user).map(&:serialize)
      json_response 'Tarefas da equipe', true, { tasks: tasks }, :ok
    else
      tasks = Task.load_user_tasks(@current_user)
      json_response 'Lista de tarefas', true, { tasks: tasks }, :ok
    end
  end

  def create
    status_id = Status.find_by(name: 'Em andamento').id
    task = Task.new(title: task_params[:title],
                    status_id: status_id,
                    start_time: Time.now,
                    user_id: @current_user.id)

    if task.save
      json_response 'Tarefa criada com sucesso', true, { task: task }, :ok
    else
      json_response 'Algo deu errado', false, {}, :unauthorized
    end
  end

  def show
    task = Task.find_by(id: params[:id])
    if task && task.user_id == @current_user.id
      json_response 'Detalhes da tarefa', true, { task: task }, :ok
    else
      json_response 'Algo deu errado', false, {}, :unauthorized
    end
  end

  def update
    task = Task.find_by(id: params[:id])
    status_id = Status.find_by(name: task_params[:status_name]).id
    end_time = Time.now unless task_params[:status_name] == 'Em andamento'

    if task && task.user_id == @current_user.id
      task.update_attributes(title: task_params[:title],
                             end_time: end_time,
                             notes: task_params[:notes],
                             status_id: status_id)
      json_response 'Tarefa atualizada com sucesso', true, { task: task }, :ok
    else
      json_response 'Não foi possível salvar', false, { task: task }, :unprocessable_entity
    end
  end

  private

  def task_params
    params.require(:task).permit(:title, :notes, :status_name)
  end
end
