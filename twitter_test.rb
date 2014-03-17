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
end
