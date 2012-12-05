require 'rest'
require 'test/unit'
require_relative 'base'

class MyUnitTest < Base

  def test_codes
    rest = Rest::Client.new
    r = rest.get("#{base_url}/code/200")
    assert_equal 200, r.code

    begin
      r = rest.get("#{base_url}/code/503")
    rescue Rest::HttpError => ex
      assert_equal 503, ex.code
    end

    begin
      r = rest.post("#{base_url}/code/503")
    rescue Rest::HttpError => ex
      assert_equal 503, ex.code
    end

    3.times do |i|
      begin
        r = rest.post("#{base_url}/code/503?switch_after=2&switch_to=200")
        assert_equal 200, r.code
        assert_equal 2, i
      rescue Rest::HttpError => ex
        assert_equal 503, ex.code
      end
    end

    # try with namespace, do one without namespace to see if it's good
    r = rest.post("#{base_url}/code/503?switch_after=2&switch_to=200")
    3.times do |i|
      begin
        r = rest.post("#{base_url}/code/503?switch_after=2&switch_to=200&namespace=test2")
        assert_equal 200, r.code
        assert_equal 2, i
      rescue Rest::HttpError => ex
        assert_equal 503, ex.code
      end
    end


  end

  def test_store

    rest = Rest::Client.new
    r = rest.get("#{base_url}/code/200?store=test1")
    assert_equal 200, r.code

    r = rest.get("#{base_url}/stored/test1")
    stored = JSON.parse(r.body)
    assert_not_nil stored['body']
    assert_not_nil stored['url']
    assert_not_nil stored['headers']

    rest.post("#{base_url}/code/200?store=test2", body: "foo")
    r = rest.get("#{base_url}/stored/test2")
    stored = JSON.parse(r.body)
    assert_not_nil stored['body']
    assert_not_nil stored['url']
    assert_not_nil stored['headers']
    assert_equal "foo", stored['body']

    xml = '<foo>bar</foo>'
    rest.post("#{base_url}/code/200?store=test3", body: xml)
    r = rest.get("#{base_url}/stored/test3")
    stored = JSON.parse(r.body)
    p stored['body']
    assert_not_nil stored['body']
    assert_not_nil stored['url']
    assert_not_nil stored['headers']
    assert_equal xml, stored['body']


    begin
      r = rest.get("#{base_url}/stored/nothere")
    rescue Rest::HttpError => ex
      assert_equal 404, ex.code
    end

  end

end

