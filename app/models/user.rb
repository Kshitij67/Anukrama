class User < ApplicationRecord
  has_secure_password
  has_many :tasks, dependent: :destroy
  has_many :labels, dependent: :destroy
end
