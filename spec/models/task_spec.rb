RSpec.describe Task, type: :model do
  it { is_expected.to belong_to(:user) }

  it {
    is_expected.to define_enum_for(:status)
      .with_values(
        %w[
          pending
          completed
        ].index_by(&:itself)
      )
      .backed_by_column_of_type(:enum)
  }

  it { should validate_presence_of(:description) }



  describe "validate: due_date" do
    context "when due_date is before today" do
      it "is invalid" do
        task = build_stubbed(:task, due_date: 1.day.ago)

        expect(task).to be_invalid
      end
    end

    context "when due_date is today" do
      it "is valid" do
        task = build_stubbed(:task, due_date: Date.today)

        expect(task).to be_valid
      end
    end

    context "when due_date is after today" do
      it "is valid" do
        task = build_stubbed(:task, due_date: 1.day.from_now)

        expect(task).to be_valid
      end
    end
  end
end
