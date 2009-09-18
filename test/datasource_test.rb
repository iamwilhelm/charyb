require File.dirname(__FILE__) + "/test_helper"

# Feature:
#   As a data harvester user
#   I want to CRUD datasources
#   So I can manage datasources
#   So I can import datasources of different kinds
class DatasourceTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    @html_mock_path = File.join(Charyb::MOCKS_ROOT, "infoplease.html")
  end

  def app
    Sinatra::Application
  end

  context "given a data harvester user" do

    context "ghen visit datasource index" do
      setup { get "/datasources" }
      
      should "see list of datasources" do
        assert :success
      end
    end

    context "and given a TextHtml datasource" do
      setup do     
        @datasource = returning(Source::TextHtml.make) do |ds|
          ds.stubs(:response_body).returns(File.open(@html_mock_path) { |f| f.read })
        end
        Source::TextHtml.expects(:find).with(@datasource.id.to_s, anything).returns(@datasource)
      end

      context "when visit a TextHtml datasource" do
        setup { get "/datasources/#{@datasource.id}/text_html" }
        should "see the datasource details" do
          assert :success
        end
      end

    end
  end

  # Scenario Outline:
  # Given a data harvester user
  # When I add a <content_type> datasource
  # Then a datasource is added
  # And the datasource has the correct content type
#   %w(text_html text_csv text_plain).each do |content_type|
#     define("test_should_add_#{content_type}_datasource") do
#       post "/datasources"
#     end
#   end


  # Given a data harvester user
  # And a datasource
  # When I update a datasource content_type
  # Then the datasource's content_type should update 
  # And the datasource's type should update
  # And redirect to new datasource type
  def test_should_update_datasource_content_type
    @datasource = Source::TextHtml.make
  end

end
