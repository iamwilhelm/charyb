require 'yaml'

require 'rubygems'
require 'facebooker'
require 'twitter'

ENV['FACEBOOK_API_KEY'] = "47d25ddec840c0df9f27abba9ee9a2cf"
ENV['FACEBOOK_SECRET_KEY'] = "57adfe16a3ce0358fa56fbc94d90e982"

module Social

  module Facebook
    SESSION_PATH = File.join(File.expand_path(File.dirname(__FILE__)), "../tmp")

    class << self
      def login
        # load any previous session otherwise create a new one
        @session = load_session

        # open the session
        begin
          @session.user.name
        rescue 
          puts "Facebook session loading failed."
          puts "Creating new session..."
          @session = Facebooker::Session::Desktop.create
          puts "Paste the URL into your web browser and login:"
          puts @session.login_url
          puts "Hit return to continue..."
          gets
          retry
        end
        save_session

        yield @session
      end

      private
      def load_session
        begin
          File.open(File.join(SESSION_PATH, 'session.fb'), 'r') do |file|
            return Marshal.load(file)
          end
        rescue
          return Facebooker::Session::Desktop.create
        end
      end

      def save_session
        puts "Saving session file at #{SESSION_PATH}"
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
