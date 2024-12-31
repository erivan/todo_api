class Task < ApplicationRecord
  belongs_to :user

  validates :description, :title, presence: true
  validates_date :due_date, on_or_after: :today, allow_blank: true

  enum :status, %w[
    pending
    completed
  ].freeze.index_by(&:itself), validate: true


  def self.ransackable_attributes(auth_object = nil)
    %w[title description user_id status due_date]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end
end
