require File.dirname(__FILE__) + "/test_helper"

# Feature:
#   As an anonymous user
#   I want to CRUD datasources
#   So I can manage datasources
#   So I can import datasources of different kinds
class DatasourceTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # Scenario:
  # Given an anonymous user
  # When I visit the datasources index
  # Then I see the list of datasources
  def test_should_see_list_of_datasources
    get "/datasources"
    assert :success
  end

  # Scenario Outline:
  # Given an anonymous user
  # When I add a <content_type> datasource
  # Then a datasource is added
  # And the datasource has the correct content type
#   %w(text_html text_csv text_plain).each do |content_type|
#     define("test_should_add_#{content_type}_datasource") do
#       post "/datasources"
#     end
#   end

  # Given an anonymous user
  # And a datasource
  # When I visit a datasource
  # Then I see datasource
  def test_should_show_datasource
    @datasource = Source::TextHtml.make
    # get "/datasources/#{@datasource.id}/text_html"
    assert :success
  end

end
