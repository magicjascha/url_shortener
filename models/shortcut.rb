class Shortcut
  include Mongoid::Document

  field :token, type: String
  field :long_url, type: String
end