class AddStatusAndTitleToTasks < ActiveRecord::Migration[8.0]
  def change
    create_enum :task_status, %w[pending completed]

    add_column :tasks, :status, :task_status, default: "pending"
    add_column :tasks, :title, :string
  end
end
