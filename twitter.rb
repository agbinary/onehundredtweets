require 'rubygems'
require 'oauth'
require 'twitter'
require 'json'
require 'mysql2'
require 'httparty'
require './env'


class OneHundredTwitter

  def initialize(client, user, db, email)
    @client = client
    @user = user
    @db = db
    @email = email
  end

  def add_db
    @client.user_timeline(@user, :count => 100).each do |tweet|
      query = "INSERT INTO tweets.tweet (user, tweet) VALUES ( '#{@user}', '#{tweet.text.gsub(/'/, " ")}')";
      @db.query(query)
    end
  end

  def create_message
    message = ""
    result = @db.query "SELECT * FROM tweet"
    result.each {|x| message << x["tweet"] + "<br>"}
    message
  end

  def send_email(message)
    url = "https://sendgrid.com/api/mail.send.json"
    response = HTTParty.post url, :body => {
        "api_user" => ENV["SENDGRID_USER"],
        "api_key" => ENV["SENDGRID_TOKEN"],
        "to" => @email,
        "from" => "ang3l_gu@hotmail.com",
        "subject" => "OneHundredTweets",
        "html" => "Estos son los ultimos 100 tweets del usuario #{@user}: <p><p> " + message
    }

    response.body
    puts "El e-mail fue enviado"
  end
end
