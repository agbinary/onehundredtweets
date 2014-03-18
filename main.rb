require "./twitter"
<<<<<<< HEAD
=======
require './env'
>>>>>>> d93847dc1c0dd81bf24fa685d85c3081bdbd7f87

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["CONSUMER_KEY"]
  config.consumer_secret     = ENV["CONSUMER_SECRET"]
  config.access_token        = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_SECRET"]
end

twitter_db = Mysql2::Client.new(host: "localhost", username: "root", password: "573300", database: "tweets")

puts "De que usuario quiere guardar los ultimos 100 tweets? "
user = gets.chomp

begin
  client.user_timeline(user)
rescue Twitter::Error::NotFound
  puts "El usuario no existe";
else
  puts "\nA que e-mail desea enviar la base de datos? "
  email = gets.chomp
  p = OneHundredTwitter.new(client, user, twitter_db, email)
  p.add_db
  message = p.create_message
  p.send_email(message)
<<<<<<< HEAD
end
=======
end
>>>>>>> d93847dc1c0dd81bf24fa685d85c3081bdbd7f87
