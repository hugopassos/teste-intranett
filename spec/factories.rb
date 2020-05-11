FactoryBot.define do
  factory :role do
    name { 'Gestor' }
  end

  factory :status do
    name { 'Em andamento' }
  end

  factory :user do
    email { 'gestor@mail.com' }
    password { '123456' }
  end

  factory :team do
    name { 'Equipe 1' }
  end

  factory :task do
    title { 'Task 1' }
  end
end
