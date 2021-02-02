ENV['APP_ENV'] = 'test'

require 'capybara/minitest'
require 'minitest/autorun'
require 'byebug'
require './url_shortener'

class IntegrationTest < Minitest::Test
  include Capybara::DSL
  Capybara.app = UrlShortener

  def teardown
    Mongoid.purge!
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def test_shortening_and_redirecting_to_a_valid_url
    #check if the first redirection from root to new page works
    visit('/')
    assert_equal('/shortcuts/new', page.current_path)
    #look if the content of the new page is present
    has_field?('long_url')
    assert page.has_button?('Submit')
    #fill in and submit a long url
    fill_in('long_url', with: 'https://github.com/teamcapybara/capybara')
    click_button('Submit')
    # look for the changes: check the headline and the input url
    assert first('h2').has_content?('Recently added by you')
    assert first('td').has_content?('https://github.com/teamcapybara/capybara')
    # look for the generated link, check if it has the parts of a shortened url and click it
    link = first('td > a')
    link_domain = link[:href][0..page.current_host.length-1]
    link_token = link[:href][page.current_host.length+1..-1]
    assert_equal(page.current_host, link_domain)
    assert_equal(8, link_token.length)
    #click the short_url and check if it redirected to the original url
    link.click()
    assert_equal('https://github.com/teamcapybara/capybara', page.current_url)
  end

  # invalid user input

  def test_entering_an_invalid_url
    #check if the first redirection from root to new page works
    visit('/')
    #fill in and submit a long url
    fill_in('long_url', with: 'https://github.com/ eamcapybara/capybara')
    click_button('Submit')
    # look for the changes: t
    # look for the error message class 'flash-error'
    assert page.has_selector?('.flash-error')
    # look for the error messages
    assert page.has_content?("Sorry, something is wrong with your input. Please try again")
    assert page.has_content?("This is not a valid url")
    # check there is no headline for added urls and no table entries
    assert page.has_no_content?('Recently added by you')
    assert page.has_no_selector?('td')
  end

  def test_requesting_a_non_existent_shortcut
    visit('/never-saved-this')
    # check redirect to new-view
    assert page.has_current_path?('/shortcuts/new')
    # look for the flash error message
    assert page.has_selector?('.flash-error')
    assert page.has_content?("Sorry, you requested a short url 'never-saved-this' that is not saved. Do you want to generate a short url?")
    # check there is no headline for added urls and no table entries
    assert page.has_no_content?('Recently added by you')
    assert page.has_no_selector?('td')
  end
end