require_relative "test_helper"

class FilterPathParameters::AssertionsTest < FilterPathParameters::TestCase
  include FilterPathParameters::Assertions
  include Rails.application.routes.url_helpers

  def test_a_filtered_path_passes
    assert_path_filtered join_path("made-up-code", script_name: "/800966886"), "made-up-code"
  end

  def test_an_unfiltered_path_fails
    error = assert_raises(Minitest::Assertion) do
      assert_path_filtered board_path("made-up-id"), "made-up-id"
    end

    assert_includes error.message, %(Expected "/boards/made-up-id" to be filtered)
  end
end
