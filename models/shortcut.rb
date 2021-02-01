class Shortcut
  include Mongoid::Document
  #default token length is 8
  TOKEN_LENGTH = (ENV['US_TOKEN_LENGTH'] || 8).to_i

  field :token, type: String
  field :long_url, type: String

  validates :token, presence: true
  validates :token, uniqueness: true
  validates :long_url, presence: true
  validate :long_url_is_an_url

  index({ token: 1 }, { unique: true, name: "token_index" })

  def self.create_unique_token(long_url)
    5.times do
      token = rand(36**TOKEN_LENGTH).to_s(36)
      shortcut = self.create(token: token, long_url: long_url)
      if shortcut.errors[:token].empty?
        return shortcut
      end
    end
    raise ApplicationError::NoUniqueTokenError, 'fails creating a unique token. You might need to enhance the number of characters'
  end

  def add_to_session(session,root_url)
    session[:shortcuts] = {} unless session[:shortcuts]
    session[:shortcuts][self.short_url(root_url)] = self.long_url
  end

  def short_url(root_url)
    "#{root_url}#{self.token}"
  end

  def long_url_with_protocol
    if self.long_url[0..7]=='https://' or self.long_url[0..6]=='http://'
      return self.long_url
    else
      return 'https://'+ self.long_url
    end
  end

  private

    def long_url_is_an_url
      errors.add(:long_url, "This is not a valid url") unless is_valid_url?(self.long_url_with_protocol)
    end

    def is_valid_url?(url)
      if (url =~ /\A#{URI::regexp}\z/) == 0
        return true
      else
        return false
      end
    end
end