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

  # creates a Shortcut record with the long_url from the input and a unique token consisting of random alphanumeric characters. The length of token is determined by the class constant TOKEN_LENGTH
  #
  # @param long_url [String]
  # @return [Shortcut]
  # @raise [ApplicationError::NoUniqueTokenError] if the database is already too full to find a unique token, an error is thrown.
  def self.create_unique_token(long_url)
    5.times do # tries to generate a non-colliding, unique token 5 times
      token = rand(36**TOKEN_LENGTH).to_s(36)
      shortcut = self.create(token: token, long_url: long_url)
      if shortcut.errors[:token].empty?
        return shortcut
      end
    end
    raise ApplicationError::NoUniqueTokenError, 'fails creating a unique token. You might need to enhance the number of characters'
  end

  # adds the shortcuts' long_url and short_url into the session as a new key-value pair
  #
  # @param session [Session] with session[:shortcuts] = {shorturl3 => long_url3, shorturl2 => longurl2, ....urls present from before...}
  # @param root_url [String] this has to be the apps domain
  # @return [Session]
  def add_to_session(session,root_url)
    session[:shortcuts] = {} unless session[:shortcuts]
    session[:shortcuts][self.short_url(root_url)] = self.long_url
    return session
  end

  # constructs the short_url from the input, which should be the apps domain and the shortcuts' token
  #
  # @param root_url [String] this has to be the apps domain
  # @return [String]
  def short_url(root_url)
    "#{root_url}#{self.token}"
  end

  # completes the protocol in the shortcuts' long url, if it is not yet included
  #
  # @return [String]
  def long_url_with_protocol
    if self.long_url[0..7]=='https://' or self.long_url[0..6]=='http://'
      return self.long_url
    else
      return 'https://'+ self.long_url
    end
  end

  private

  # custom validator: checks if the shortcuts' long-url is a valid url
    def long_url_is_an_url
      errors.add(:long_url, "This is not a valid url") unless is_valid_url?(self.long_url_with_protocol)
    end

  # helper method: checks if an url is a valid url
  #
  # @return [Boolean]
    def is_valid_url?(url)
      if (url =~ /\A#{URI::regexp}\z/) == 0
        return true
      else
        return false
      end
    end
end