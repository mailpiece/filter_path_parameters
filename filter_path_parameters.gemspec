$LOAD_PATH.push File.expand_path('lib', __dir__)
require_relative "lib/filter_path_parameters/version"

Gem::Specification.new do |spec|
  spec.name = "filter_path_parameters"
  spec.version = FilterPathParameters::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = ">= 3.4"
  spec.authors = [ "Simon Lev" ]

  spec.summary = "Keep credentials carried in a Rails path segment out of the log."
  spec.description = "Rails' filter_parameters filters query strings and form bodies from the log but never path segments. Declare which dynamic segments of which routes are credentials, and the Started line, the process_action event, the Redirected line and the routing error message show [FILTERED] in their place."

  spec.homepage = "https://github.com/mailpiece/filter_path_parameters"
  spec.license = "MIT"

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir[
    "lib/**/*.rb",
    "CHANGELOG.md",
    "README.md",
    "LICENSE",
    "filter_path_parameters.gemspec"
  ]
  spec.require_paths = [ "lib" ]

  spec.add_dependency "railties", ">= 8.0"
  spec.add_dependency "actionpack", ">= 8.0"
end
