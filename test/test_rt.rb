require 'rest'
require 'test/unit'

class MyUnitTest < Test::Unit::TestCase
  def test_store

    rest = Rest::Client.new
    rest.get("http://localhost:9292/code/200?store=test1")

    r = rest.get("http://localhost:9292/stored/test1")

    stored = JSON.parse(r.body)
    assert_not_nil stored['body']
    assert_not_nil stored['url']
    assert_not_nil stored['headers']

  end

end

