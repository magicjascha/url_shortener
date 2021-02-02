ENV['APP_ENV'] = 'test'

require 'test/unit'
require 'rack/test'
require 'minitest/autorun'
require 'byebug'
require './url_shortener'

class ModelTest < Minitest::Test
  include Rack::Test::Methods

  def app
    UrlShortener
  end

  def setup
    Mongoid.purge!
    @valid_url = 'https://github.com/teamcapybara/capybara'
    @invalid_url = 'https://github.com teamca pybara/capybara'
  end

  def test_create_works
    Shortcut.create(token: 'lalalala', long_url: @valid_url)
    assert(Shortcut.find_by(token: 'lalalala').present?)
  end

  def test_create_with_blank_long_url_fails
    shortcut = Shortcut.create(token: 'lalalala', long_url: '')
    assert(shortcut.invalid?)
    assert_equal(0, Shortcut.all.count)
  end

  def test_create_with_wrong_characters_in_long_url_fails
    shortcut = Shortcut.create(token: 'lalalala', long_url: @invalid_url)
    assert(shortcut.invalid?)
    assert_equal(0, Shortcut.all.count)
  end

  def test_create_for_non_unique_token_fails
    Shortcut.create(token: 'lalalala', long_url: @valid_url)
    assert_equal(1, Shortcut.all.count)
    shortcut = Shortcut.create(token: 'lalalala', long_url: @valid_url)
    assert(shortcut.invalid?)
    assert_equal(1, Shortcut.all.count)
  end

  def test_create_for_blank_token_fails
    shortcut = Shortcut.create(token: '', long_url: @invalid_url)
    assert(shortcut.invalid?)
    assert_equal(0, Shortcut.all.count)
  end

  def test_create_a_unique_token_works
    shortcut = Shortcut.create_unique_token(@valid_url)
    assert(shortcut.valid?)
    assert_equal(1, Shortcut.where(long_url: @valid_url).count)
  end

  def test_short_url
    shortcut = Shortcut.create(token: 'lalalala', long_url: @valid_url)
    short_url = shortcut.short_url('my.domain.de/')
    assert_equal('my.domain.de/'+shortcut.token, short_url)
  end

  def test_long_url_with_protocol_adds_https
    shortcut = Shortcut.create_unique_token('github.com/teamcapybara/capybara')
    assert_equal('https://github.com/teamcapybara/capybara', shortcut.long_url_with_protocol)
  end

  def test_long_url_with_protocol_returns_complete_https_url
    shortcut = Shortcut.create_unique_token('https://github.com/teamcapybara/capybara')
    assert_equal('https://github.com/teamcapybara/capybara', shortcut.long_url_with_protocol)
  end

  def test_long_url_with_protocol_returns_complete_https_url
    shortcut = Shortcut.create_unique_token('https://github.com/teamcapybara/capybara')
    assert_equal('https://github.com/teamcapybara/capybara', shortcut.long_url_with_protocol)
  end
end