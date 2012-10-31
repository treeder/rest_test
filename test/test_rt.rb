require 'rest'
require 'test/unit'

class MyUnitTest < Test::Unit::TestCase
  def test_store

    rest = Rest::Client.new
    r = rest.get("http://localhost:9292/code/200?store=test1")
    assert_equal 200, r.code

    r = rest.get("http://localhost:9292/stored/test1")

    stored = JSON.parse(r.body)
    assert_not_nil stored['body']
    assert_not_nil stored['url']
    assert_not_nil stored['headers']

    rest.post("http://localhost:9292/code/200?store=test2", body: "foo")
    r = rest.get("http://localhost:9292/stored/test2")

    stored = JSON.parse(r.body)
    assert_not_nil stored['body']
    assert_not_nil stored['url']
    assert_not_nil stored['headers']
    assert_equal "foo", stored['body']

    xml = '<foo>bar</foo>'
    rest.post("http://localhost:9292/code/200?store=test3", body: xml)
    r = rest.get("http://localhost:9292/stored/test3")

    stored = JSON.parse(r.body)
    p stored['body']
    assert_not_nil stored['body']
    assert_not_nil stored['url']
    assert_not_nil stored['headers']
    assert_equal xml, stored['body']


  end

end

