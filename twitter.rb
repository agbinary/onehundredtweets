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

puts "De que usuario quiere guardar los ultimos 100 tweets? "
user=gets.chomp

client.user_timeline(user, :count => 100).each do |tweet|
  h="INSERT INTO tweets.tweet (user, tweet) VALUES ( '#{user}', '#{tweet.text.gsub(/'/, " ")}')";
  twitter_db.query h
end

if client.search(user)==NoMethodError
  puts "El usuario no existe"
end

result=twitter_db.query "SELECT * FROM tweet"
todos=""
result.each {|x| todos << x["tweet"] + "<br>"}

puts "\nA que e-mail desea enviar la base de datos? "
email=gets.chomp

url = "https://sendgrid.com/api/mail.send.json"

response = HTTParty.post url, :body => {
    "api_user" => "ang3l_gu",
    "api_key" => "57-33-00.a",
    "to" => email,
    "from" => "ang3l_gu@hotmail.com",
    "subject" => "OneHundredTweets",
    "html" => "Estos son los ultimos 100 tweets del usuario #{user}: <p><p> " + todos

}
response.body
puts "El e-mail fue enviado"










