class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_many :tasks, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    %w[email]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[tasks]
  end
end
