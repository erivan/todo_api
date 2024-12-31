describe Api::V1::UsersController, type: :request do
  describe "#index" do
    context "when user is authenticated" do
      context "when no filters are given" do
        it "returns all tasks" do
          user = create(:user)
          token = sign_in_user(user)

          users = create_list(:user, 3)

          get api_v1_users_path, headers: { Authorization: token }

          expect(response).to have_http_status(:ok)
          expect(json_response[:data].size).to eq(4)

          users + [ user ].each do |user|
            expect(json_response[:data]).to include a_hash_including(
              id: user.id.to_s,
              attributes: include({
                email: user.email
              })
            )
          end
        end
      end

      context "when filters are given" do
        it "returns tasks for the given filter" do
          user = create(:user, email: "john@doe.com")
          token = sign_in_user(user)

          _users = create_list(:user, 3)

          params = { q: { email_eq: user.email } }

          get api_v1_users_path, headers: { Authorization: token }, params: params

          expect(response).to have_http_status(:ok)

          expect(json_response[:data].size).to eq(1)

          expect(json_response[:data]).to include a_hash_including(
            id: user.id.to_s,
            attributes: include({
              email: user.email
            })
          )

          # sanity check
          expect(User.count).to eq(4)
        end
      end

      context "when user is not authenticated" do
        it "returns unauthorized" do
          get api_v1_users_path

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
