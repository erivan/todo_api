class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  validates :jti, presence: true
end
