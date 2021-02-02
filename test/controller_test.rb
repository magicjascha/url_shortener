ENV['APP_ENV'] = 'test'

require 'test/unit'
require 'rack/test'
require 'minitest/autorun'
require 'byebug'
require './url_shortener'

class ControllerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    UrlShortener
  end

  def setup
    Mongoid.purge!
    @long_url = 'https://github.com/teamcapybara/capybara'
  end

  def test_get_root_redirects_to_new
    response = get("/")
    assert_equal(302, response.status)
    assert(response.header["location"].end_with?("/shortcuts/new"))
  end

  def test_get_new_works
    response = get("/shortcuts/new")
    assert_equal(200, response.status)
  end

  def test_post_valid_url_saves_to_database
    nr_database_records = Shortcut.all.count
    #post short_url
    post('/shortcuts', { "long_url": @long_url})
    #check that there is one new database record with the input-long_url
    assert_equal(nr_database_records+1, Shortcut.all.count)
    assert(Shortcut.find_by(long_url: @long_url).present?)
  end

  def test_post_valid_url_redirects_to_new
    response = post('/shortcuts', { "long_url": @long_url})
    assert_equal(302, response.status)
    assert(response.header["location"].end_with?("/shortcuts/new"))
  end

  def test_get_short_url_redirects
    #setup a record
    shortcut = Shortcut.create_unique_token( @long_url)
    #test
    response = get("/#{shortcut.token}")
    assert_equal(302, response.status)
    assert_equal(shortcut.long_url, response.header["location"])
  end

  # invalid user input

  def test_entering_invalid_url_does_not_save_to_database
    original_nr_database_records = Shortcut.all.count
    post('/shortcuts', { "long_url": 'invalid string with spaces'})
    assert_equal(original_nr_database_records, Shortcut.all.count)
  end

  def test_entering_invalid_url_does_not_redirect
    response = post('/shortcuts', { "long_url": 'invalid string with spaces'})
    # no redirect
    assert_equal(200, response.status)
  end

  def test_get_non_existent_short_url_redirects_to_new
    response = get("/non-existent-token")
    # redirect to new-path
    assert_equal(302, response.status)
    assert(response.header["location"].end_with?("/shortcuts/new"))
  end
end