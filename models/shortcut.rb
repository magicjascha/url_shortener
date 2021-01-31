class Shortcut
  include Mongoid::Document

  field :token, type: String
  field :long_url, type: String

  validates :token, presence: true
  validates :token, uniqueness: true
  validates :long_url, presence: true

  index({ token: 1 }, { unique: true, name: "token_index" })

  def self.create_unique_token(long_url)
    5.times do
      token = rand(36**8).to_s(36)
      shortcut = self.create(token: token, long_url: long_url)
      if shortcut.errors[:token].empty?
        return shortcut
      end
      raise StandardError, 'fails creating a unique token'
    end
  end
end