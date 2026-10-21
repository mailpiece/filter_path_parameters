# filter_path_parameters

🔏 Keep credentials carried in a Rails path segment out of the log.

Rails' `config.filter_parameters` filters query strings and form bodies from the log, but never path segments. A join code at `/join/:code`, a session transfer id, a signed token at `/mailboxes/:id/forwardings/:token/confirmation` all reach the production log in full. Declare which segments of which routes are credentials, and the log shows `[FILTERED]` in their place.

**filter_path_parameters** reproduces the path filter of a private gem, with the same public surface.

## Contents

- [Installation](#installation)
- [Why](#why)
- [Declaring Routes](#declaring-routes)
- [A Prefix](#a-prefix)
- [Filtering a Path Yourself](#filtering-a-path-yourself)
- [Testing Your Routes](#testing-your-routes)
- [What Is Filtered](#what-is-filtered)
- [Why These Are Overrides](#why-these-are-overrides)
- [The Proxy in Front](#the-proxy-in-front)
- [Testing](#testing)
- [History](#history)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "filter_path_parameters"
```

Requires Ruby >= 3.4 and Rails >= 8.0.

## Why

Four lines carry the path of a request into the log, and `filter_parameters` touches none of them:

- `Started GET "/join/k7m2x9qp4" for ...`, which `Rails::Rack::Logger` writes from `request.filtered_path`
- the `path` of the `process_action.action_controller` event, set from `request.filtered_path`, which every structured log subscriber reads
- `Redirected to https://app.example/join/k7m2x9qp4`, from `response.filtered_location`
- `ActionController::RoutingError (No route matches [GET] "/join/k7m2x9qp4/xmlrpc.php")`, raised with the raw `PATH_INFO` when no route matches, so a scanner probing a join link gets a 404 whose logged message still holds the code

A join link before:

```
Started GET "/800966886/join/k7m2x9qp4?utm=mail" for 203.0.113.9 at 2026-10-21 09:12:04 +0000
Processing by JoinCodesController#new as HTML
  Parameters: {"code" => "[FILTERED]"}
Redirected to https://app.example/800966886/join/k7m2x9qp4/account
```

And after:

```
Started GET "/800966886/join/[FILTERED]?utm=mail" for 203.0.113.9 at 2026-10-21 09:12:04 +0000
Processing by JoinCodesController#new as HTML
  Parameters: {"code" => "[FILTERED]"}
Redirected to https://app.example/800966886/join/[FILTERED]/account
```

Only what is logged changes. The request path, routing, `request.path`, `fullpath`, `original_url` and what the app serves are untouched.

## Declaring Routes

In `config/routes.rb`, wrap the routes in `filter_path_parameters` and name the segments that are credentials. Every route drawn inside the block is marked, nested ones included:

```ruby
filter_path_parameters :code do
  get "join/:code", to: "join_codes#new", as: :join
  post "join/:code", to: "join_codes#create"
end

filter_path_parameters :token, :forwarding_token do
  resources :forwardings, param: :token, only: :create do
    resource :confirmation, only: %i[ show create ]
  end
end
```

A path is filtered when it starts with a declared route's segments, whether or not anything routes the rest, so `/join/k7m2x9qp4/xmlrpc.php` becomes `/join/[FILTERED]/xmlrpc.php`. A declared segment is one whole path segment, format suffix included: `/join/k7m2x9qp4.json` becomes `/join/[FILTERED]`. A glob (`*path`) takes the rest of the path. A dynamic segment that is not declared, like the `:id` in `/mailboxes/:id/forwardings/:token`, matches any segment and is kept. Whatever follows the last declared segment is left alone. Rails squeezes repeated slashes before routing, so `//join/k7m2x9qp4` is matched too, and a literal in another case is filtered rather than logged.

Filtering more than needed is fine; too little is not. Blocks nest, and the names of each block apply to the routes drawn inside it.

Routes reload in development; the declarations are rebuilt with every draw and never accumulate across reloads.

## A Prefix

An optional regexp matched at the start of the path and kept unchanged; the declared routes are matched after it. For an app that mounts tenants at a prefix its own middleware moves from `PATH_INFO` to `SCRIPT_NAME` before routing, so that the routes themselves are drawn unprefixed:

```ruby
# config/initializers/filter_path_parameters.rb
FilterPathParameters.prefix = /\A(\/\d{6,})/
```

The prefix is optional in the match, so a path without it, say a `Referer` of `/join/k7m2x9qp4`, is filtered too.

## Filtering a Path Yourself

```ruby
FilterPathParameters.filter_path("/800966886/join/k7m2x9qp4")       # => "/800966886/join/[FILTERED]"
FilterPathParameters.filter_path("/join/k7m2x9qp4/xmlrpc.php")      # => "/join/[FILTERED]/xmlrpc.php"
FilterPathParameters.filter_path("/boards/42")                      # => "/boards/42", not declared
FilterPathParameters.filter_url("https://x.test/800966886/join/abc?x=1")
# => "https://x.test/800966886/join/[FILTERED]?x=1"
```

`filter_url` filters the path of a URL and keeps its scheme, host, query and fragment as they are. It takes a bare path too, and a string that is no URL comes back unchanged rather than raising.

## Testing Your Routes

A test pinning that a credential path stays filtered, with the real route helpers:

```ruby
class CredentialPathsTest < ActiveSupport::TestCase
  include FilterPathParameters::Assertions
  include Rails.application.routes.url_helpers

  test "a join code is filtered" do
    assert_path_filtered join_path("made-up-code", script_name: "/800966886"), "made-up-code"
  end
end
```

## What Is Filtered

- `request.filtered_path`: the `Started` line, the `path` of the `process_action.action_controller` event, and whatever reads either
- `response.filtered_location`: the `Redirected to` line and the `location` of the same event
- the message of `ActionController::RoutingError`, in the exception itself, so the line `ActionDispatch::DebugExceptions` logs and whatever an error reporter is handed are both filtered

Rails' own filtering of the query string and of the redirect location stays as it is; the path filter runs on top of it.

## Why These Are Overrides

Rails has no hook for any of this: `filtered_path` and `filtered_location` are computed and read inside Rails, and the routing error is raised with the raw path. Each override is a module prepended from the railtie, calls `super`, and filters the result. It is the same thing the private gem it reproduces does, and `test/overrides_test.rb` pins that each method is still there on the Rails in the bundle, so a Rails that renames one fails loudly instead of leaking quietly.

| Rails method | Override | For |
| --- | --- | --- |
| `ActionDispatch::Http::FilterParameters#filtered_path` | `FilterPathParameters::Request` | the `Started` line and the `process_action` event |
| `ActionDispatch::Http::FilterRedirect#filtered_location` | `FilterPathParameters::Response` | the `Redirected to` line |
| `ActionController::RoutingError#initialize` | `FilterPathParameters::RoutingError` | the `No route matches` message |
| `ActionDispatch::Routing::RouteSet#clear!` | `FilterPathParameters::RouteSet` | dropping a route set's declarations when its routes are cleared for a redraw |

`filter_path_parameters` itself is a method added to `ActionDispatch::Routing::Mapper`, not an override.

## The Proxy in Front

The proxy in front of the app logs the raw path before the app sees it. [kamal-proxy](https://github.com/basecamp/kamal-proxy)'s `--log-filter-path` (branch `log-filter-path`), which Kamal sets through `proxy.logging.filter_paths`, is the matching setting there.

## Testing

```sh
bundle install
rake
```

The tests run against the Rails `main` the Gemfile pins, in a small in-process application.

## History

View the [changelog](CHANGELOG.md).

## Contributing

Everyone is encouraged to help improve this project:

- [Report bugs](https://github.com/mailpiece/filter_path_parameters/issues)
- Fix bugs and submit pull requests
- Write, clarify, or fix documentation
- Suggest or add new features

## License

MIT. See [LICENSE](LICENSE).
