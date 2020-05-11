# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Role.create(name: 'Gestor')
Role.create(name: 'Colaborador')

Team.create(name: 'Equipe 1')

User.create(email: 'teste@mail.com', password: '123456', role_id: Role.second.id, team_id: Team.first.id)
User.create(email: 'teste2@mail.com', password: '123456', role_id: Role.second.id, team_id: Team.first.id)
User.create(email: 'gestor@mail.com', password: '123456', role_id: Role.first.id, team_id: Team.first.id)

Status.create(name: 'Em andamento')
Status.create(name: 'Finalizado')
Status.create(name: 'Cancelado')

Task.create(title: 'Teste 1', start_time: Time.now, status_id: Status.first.id, user_id: User.first.id)
Task.create(title: 'Teste 2', start_time: Time.now, status_id: Status.first.id, user_id: User.first.id)
Task.create(title: 'Teste 3', start_time: Time.now, status_id: Status.first.id, user_id: User.first.id)

Task.create(title: 'Teste 4', start_time: Time.now, status_id: Status.first.id, user_id: User.second.id)
Task.create(title: 'Teste 5', start_time: Time.now, status_id: Status.first.id, user_id: User.second.id)
Task.create(title: 'Teste 6', start_time: Time.now, status_id: Status.first.id, user_id: User.second.id)
