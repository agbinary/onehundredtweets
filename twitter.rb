require 'rubygems'
require 'oauth'
require 'twitter'
require 'json'
require 'mysql2'
require 'httparty'
require './env'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["CONSUMER_KEY"]
  config.consumer_secret     = ENV["CONSUMER_SECRET"]
  config.access_token        = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_SECRET"]
end

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

twitter_db = Mysql2::Client.new(host: "localhost", username: "root", password: "573300", database: "tweets")

def add_db (client, user, db)
  client.user_timeline(user, :count => 100).each do |tweet|
  h="INSERT INTO tweets.tweet (user, tweet) VALUES ( '#{user}', '#{tweet.text.gsub(/'/, " ")}')";
  db.query h
  end
end

def create_message(db)
  result=db.query "SELECT * FROM tweet"
  all=""
  result.each {|x| all << x["tweet"] + "<br>"}
  all
end

def send_email(user, email, mensaje)
  url = "https://sendgrid.com/api/mail.send.json"
  response = HTTParty.post url, :body => {
      "api_user" => ENV["SENDGRID_USER"],
      "api_key" => ENV["SENDGRID_TOKEN"],
      "to" => email,
      "from" => "ang3l_gu@hotmail.com",
      "subject" => "OneHundredTweets",
      "html" => "Estos son los ultimos 100 tweets del usuario #{user}: <p><p> " + mensaje

  }
  response.body
  puts "El e-mail fue enviado"
end

puts "De que usuario quiere guardar los ultimos 100 tweets? "
user=gets.chomp

begin
  client.user_timeline(user)
rescue Twitter::Error::NotFound
  puts "El usuario no existe";
else
  add_db(client, user, twitter_db)
  message=create_message(twitter_db)
  puts "\nA que e-mail desea enviar la base de datos? "
  email=gets.chomp
  send_email(user, email, message)

end












