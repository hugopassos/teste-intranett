class TaskSerializer < ActiveModel::Serializer
  attribute :title
  attribute :start_time
  attribute :end_time
  attribute :notes
  attribute :status_name

  def status_name
    object.status.name
  end
end
