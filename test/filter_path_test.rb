require_relative "test_helper"

class FilterPathParameters::FilterPathTest < FilterPathParameters::TestCase
  def test_a_declared_segment_is_filtered
    assert_equal "/join/[FILTERED]", filter("/join/k7m2x9qp4")
  end

  def test_the_prefix_is_kept
    assert_equal "/800966886/join/[FILTERED]", filter("/800966886/join/k7m2x9qp4")
  end

  def test_the_prefix_is_optional
    assert_equal "/join/[FILTERED]", filter("/join/k7m2x9qp4")
  end

  def test_what_follows_the_declared_segment_is_left_alone
    assert_equal "/join/[FILTERED]/xmlrpc.php", filter("/join/k7m2x9qp4/xmlrpc.php")
  end

  # The segment is the credential whether or not it ends in a format, so the whole of it goes.
  def test_a_format_suffix_goes_with_the_segment
    assert_equal "/join/[FILTERED]", filter("/join/k7m2x9qp4.json")
  end

  def test_an_undeclared_segment_before_a_declared_one_is_kept
    assert_equal "/mailboxes/42/forwardings/[FILTERED]/confirmation",
      filter("/mailboxes/42/forwardings/t0k3n/confirmation")
    assert_equal "/mailboxes/42/forwardings/[FILTERED]",
      filter("/mailboxes/42/forwardings/t0k3n")
  end

  def test_a_route_without_a_declared_segment_is_not_filtered
    assert_equal "/mailboxes/42/forwardings", filter("/mailboxes/42/forwardings")
  end

  def test_a_glob_takes_the_rest
    assert_equal "/files/[FILTERED]", filter("/files/secret/deep/path.txt")
  end

  def test_an_undeclared_route_is_unchanged
    assert_equal "/boards/42", filter("/boards/42")
    assert_equal "/800966886/boards/42", filter("/800966886/boards/42")
  end

  def test_a_declared_route_elsewhere_in_the_path_is_unchanged
    assert_equal "/boards/join/abc", filter("/boards/join/abc")
  end

  # Rails routes //join/abc as /join/abc, so it is filtered as that too.
  def test_repeated_slashes_are_matched
    assert_equal "//join/[FILTERED]", filter("//join/k7m2x9qp4")
    assert_equal "/800966886//join//[FILTERED]", filter("/800966886//join//k7m2x9qp4")
  end

  def test_a_literal_in_another_case_is_matched
    assert_equal "/JOIN/[FILTERED]", filter("/JOIN/k7m2x9qp4")
  end

  def test_encoded_characters_are_left_as_is
    assert_equal "/join/[FILTERED]/a%20b", filter("/join/k7m%2Bx9/a%20b")
    assert_equal "/boards/a%20b", filter("/boards/a%20b")
  end

  def test_nil_and_empty_input
    assert_nil filter(nil)
    assert_equal "", filter("")
  end

  def test_the_input_is_not_changed
    path = "/join/k7m2x9qp4"
    filter(path)

    assert_equal "/join/k7m2x9qp4", path
  end
end
