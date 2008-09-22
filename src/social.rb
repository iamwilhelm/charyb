require 'yaml'

require 'rubygems'
require 'facebooker'
require 'twitter'

module Social

  module Facebook
    API_KEY = "47d25ddec840c0df9f27abba9ee9a2cf"
    SECRET_KEY = "57adfe16a3ce0358fa56fbc94d90e982"
    SESSION_PATH = File.join(File.expand_path(File.dirname(__FILE__)), "../tmp")

    class << self
      def login
        # open the session
        begin
          puts "Loading saved session from file"
          File.open(File.join(SESSION_PATH, 'session.fb'), 'r') do |file|
            @session = Marshal.load(file)
          end
          @session.user.name
        rescue 
          puts "Failed."
          puts "Creating new session"
          @session = Facebooker::Session::Desktop.create(API_KEY, SECRET_KEY)
          puts "Paste the URL into your web browser and login:"
          puts @session.login_url
          puts "Hit return to continue..."
          gets
        end

        yield @session

        # save the session
        File.open(File.join(SESSION_PATH, 'session.fb'), 'w') do |file|
          Marshal.dump(@session, file)
        end
      end
    end
  end

  module Twitter
    class << self
      def login
        session = Kernel::Twitter::Base.new('iamwil', 'cestfaux')
        yield session
      end
    end
  end


end
