class TaskSerializer
  include JSONAPI::Serializer
  attributes :title, :description, :user_id, :status

  attribute :due_date do |task|
    task.due_date.strftime("%Y-%m-%d") if task.due_date
  end
end
