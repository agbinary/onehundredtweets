require "./twitter"
require "minitest/autorun"
require "mocha/mini_test"

class OneHunderdTwitterTest < Minitest::Test
  def test_add_db
    client = mock
    tweet = mock
    db = mock

    tweet.expects(:text).returns("Hello, Angie")
    client.expects(:user_timeline).returns([tweet])
    db.expects(:query).with("INSERT INTO tweets.tweet (user, tweet) VALUES ( 'guille', 'Hello, Angie')").returns(true)

    app = OneHundredTwitter.new(client, 'guille', db, 'angie@gmail.com')

    assert app.add_db
  end

  def test_create_message
    client = mock
    db = mock

    db.expects(:query).with("SELECT * FROM tweet").returns([{"tweet" => "Hello, Angie"}])

    app = OneHundredTwitter.new(client, 'guille', db, 'angie@gmail.com')

    assert_equal "Hello, Angie<br>", app.create_message
  end

  def test_send_email
    sendgrid_user = ENV["SENDGRID_USER"]
    sendgrid_token = ENV["SENDGRID_TOKEN"]

    ENV["SENDGRID_USER"] = "user"
    ENV["SENDGRID_TOKEN"] = "key"

    hash = {
      :body => {
        "api_user" => "user",
        "api_key" => "key",
        "to" => "angie@gmail.com",
        "from" => "ang3l_gu@hotmail.com",
        "subject" => "OneHundredTweets",
        "html" => "Estos son los ultimos 100 tweets del usuario guille: <p><p> Hola, Angie<br>"
      }
    }

    client = mock
    db = mock
    response = mock

    response.expects(:body)

    HTTParty.expects(:post).with("https://sendgrid.com/api/mail.send.json", hash).returns(response)

    app = OneHundredTwitter.new(client, 'guille', db, 'angie@gmail.com')

    out, _ = capture_io do
      app.send_email("Hola, Angie<br>")
    end

    assert_equal "El e-mail fue enviado\n", out
  ensure
    ENV["SENDGRID_USER"] = sendgrid_user
    ENV["SENDGRID_TOKEN"] = sendgrid_token
  end
end
