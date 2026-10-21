require_relative "test_helper"

class FilterPathParameters::FilterUrlTest < FilterPathParameters::TestCase
  def test_scheme_host_query_and_fragment_are_kept
    assert_equal "https://x.test/800966886/join/[FILTERED]?x=1#top",
      FilterPathParameters.filter_url("https://x.test/800966886/join/abc?x=1#top")
  end

  def test_a_bare_path
    assert_equal "/join/[FILTERED]?x=1", FilterPathParameters.filter_url("/join/abc?x=1")
  end

  def test_a_bare_path_without_a_query
    assert_equal "/join/[FILTERED]", FilterPathParameters.filter_url("/join/abc")
  end

  def test_an_unparsable_string_does_not_raise
    assert_equal "http://[::1/join/[FILTERED]", FilterPathParameters.filter_url("http://[::1/join/abc")
    assert_equal "not a url", FilterPathParameters.filter_url("not a url")
    assert_equal "[FILTERED]", FilterPathParameters.filter_url("[FILTERED]")
  end

  def test_nil
    assert_nil FilterPathParameters.filter_url(nil)
  end
end
