describe Api::V1::TasksController, type: :request do
  describe "#index" do
    context "when user is authenticated" do
      context "when no filters are given" do
        it "returns all tasks" do
          user = create(:user)
          token = sign_in_user(user)

          task = create(:task, user: user)

          get api_v1_tasks_path, headers: { Authorization: token }

          expect(response).to have_http_status(:ok)
          expect(json_response[:data]).to include a_hash_including(
            id: task.id.to_s,
            attributes: include(
              title: task.title,
              description: task.description,
              status: task.status,
              due_date: task.due_date.strftime("%Y-%m-%d"),
              user_id: task.user_id
            )
          )
        end
      end

      context "when filters are given" do
        it "returns tasks for the given filter" do
          user = create(:user)
          token = sign_in_user(user)

          task = create(:task, user: user)
          _task2 = create(:task, title: "another", user: user)

          params = { q: { title_eq: task.title } }

          get api_v1_tasks_path, headers: { Authorization: token }, params: params

          expect(response).to have_http_status(:ok)

          expect(json_response[:data]).to include a_hash_including(
            id: task.id.to_s,
            attributes: include(
              title: task.title,
              description: task.description,
              status: task.status,
              due_date: task.due_date.strftime("%Y-%m-%d"),
              user_id: task.user_id
            )
          )
        end

        context "when filter for invalid status is given" do
          it "returns unprocessable entity" do
            user = create(:user)
            token = sign_in_user(user)

            _task = create(:task, user: user)

            params = { q: { status_eq: "invalid" } }

            get api_v1_tasks_path, headers: { Authorization: token }, params: params

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context "when user is not authenticated" do
        it "returns unauthorized" do
          get api_v1_tasks_path

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  describe "#show" do
    context "when user is authenticated" do
      it "returns the task" do
        user = create(:user)
        token = sign_in_user(user)

        task = create(:task, user: user)
        _task2 = create(:task, title: "another", user: user)

        get api_v1_task_path(task), headers: { Authorization: token }

        expect(response).to have_http_status(:ok)
        expect(json_response[:data]).to eq(
          id: task.id.to_s,
          type: "task",
          attributes: {
            title: task.title,
            description: task.description,
            status: task.status,
            due_date: task.due_date.strftime("%Y-%m-%d"),
            user_id: task.user_id
      }
        )
      end

      context "when task does not exist" do
        it "returns not found" do
          user = create(:user)
          token = sign_in_user(user)

          get api_v1_task_path(1), headers: { Authorization: token }

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        task = create(:task)

        get api_v1_task_path(task)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "#create" do
    context "when user is authenticated" do
      context "when params are valid" do
        it "creates a task" do
          user = create(:user)
          token = sign_in_user(user)

          task_params = attributes_for(:task).merge(user_id: user.id)

          expect {
            post api_v1_tasks_path, headers: { Authorization: token }, params: { task: task_params }
          }.to change(Task, :count).by(1)

          expect(response).to have_http_status(:created)

          created_task = Task.find(json_response[:data][:id])

          expect(created_task).to have_attributes(task_params.except(:user_id))
        end
      end

      context "when params are invalid" do
        it "returns errors" do
          user = create(:user)
          token = sign_in_user(user)

          task_params = attributes_for(:task).merge(user_id: user.id, title: nil)

          post api_v1_tasks_path, headers: { Authorization: token }, params: { task: task_params }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response).to eq(errors: [ "Title can't be blank" ])
        end
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        task_params = attributes_for(:task)

        post api_v1_tasks_path, params: { task: task_params }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "#update" do
    context "when user is authenticated" do
      context "when task does not exist" do
        it "returns not found" do
          user = create(:user)
          token = sign_in_user(user)

          task = create(:task, user: user)

          task_params = { title: "new title" }

          patch api_v1_task_path(-1), headers: { Authorization: token }, params: { task: task_params }

          expect(response).to have_http_status(:not_found)

          expect(task.reload.title).to_not eq(task_params[:title])
        end
      end

      context "when params are valid" do
        it "updates the task" do
          user = create(:user)
          token = sign_in_user(user)

          task = create(:task, user: user)

          task_params = { title: "new title" }

          patch api_v1_task_path(task), headers: { Authorization: token }, params: { task: task_params }

          expect(response).to have_http_status(:ok)

          task.reload

          expect(task).to have_attributes(task_params)
        end
      end

      context "when params are invalid" do
        it "returns errors" do
          user = create(:user)
          token = sign_in_user(user)

          task = create(:task, user: user)

          task_params = { title: nil }

          patch api_v1_task_path(task), headers: { Authorization: token }, params: { task: task_params }

          expect(response).to have_http_status(:unprocessable_entity)

          expect(json_response).to eq(errors: [ "Title can't be blank" ])
        end
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        task = create(:task)

        task_params = attributes_for(:task)

        patch api_v1_task_path(task), params: { task: task_params }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "#destroy" do
    context "when user is authenticated" do
      context "when task does not exist" do
        it "returns not found" do
          user = create(:user)
          token = sign_in_user(user)

          task = create(:task, user: user)

          delete api_v1_task_path(-1), headers: { Authorization: token }

          expect(response).to have_http_status(:not_found)

          expect { task.reload }.to_not raise_error
        end
      end

      context "when task exists" do
        it "deletes the task" do
          user = create(:user)
          token = sign_in_user(user)

          task = create(:task, user: user)
          task2 = create(:task, user: user)

          expect {
            delete api_v1_task_path(task), headers: { Authorization: token }
          }.to change(Task, :count).by(-1)

          expect(response).to have_http_status(:no_content)
          expect { task.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { task2.reload }.to_not raise_error
        end
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        task = create(:task)

        delete api_v1_task_path(task)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
