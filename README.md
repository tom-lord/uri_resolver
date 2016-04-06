# UriResolver

Checking whether a URI resolves manually is easy: You simply enter it into your
browser and wait to see what happens!

Scripting this is normally quite easy, too. Some things you might try are:

* Check if the URI is a valid format, i.e. does it match `URI::regexp`?
* Ping the URI, and check for a response.
* Try using `URI.parse` or `Net::HTTP.get`, and rescue if `Errno::ECONNREFUSED`?

For *most* URIs a simple method like the above works fine.

However, for many "obscure" websites, such as those registered in new GTLDs, you
run into all sorts of trouble attempting this - especially when checking a very
long list! For example:

* Even a simple `ping` (i.e. opening a TCP connection) can *freeze* while
connecting to the DNS server  - which causes it to take ~20 seconds to check
just one URI!!
* Some URIs resolve via many layers of redirections.
* Some URIs resolve, but to "invalid" URIs which contain escape sequences.
* The URI may resolve to a HTTPS connection with no/a misconfigured SSL certificate.
* The URI may connect, but fails/times out when attempting to *read* any data.

This ruby gem attempts to gracefully account for all of these edge cases (and more),
by use of intelligent error handling. It also uses a multi threaded approach to prevent
system-blocking timeouts.

It's a pretty simplistic solution, but will hopefully be useful to others.

## Installation

Feel free to use this as you like, but I'm currently experimenting with it;
implementation may change significantly, until `v1.0.0` is published.


Add this line to your application's Gemfile:

```ruby
gem 'uri_resolver'
```

And then execute:

    $ bundle

## Usage

    UriResolver.resolve_status "google.com"        # => :resoves
    UriResolver.resolve_status "sakjflkdjsfh.com"  # => :does_not_resolve

    # If the connection times out, then the gem returns :maybe_resolves
    UriResolver.resolve_status "getmintedpoker.tv" # => :maybe_resolves
    # Such URIs *probably* don't resolve, but a manual check may be a good idea

Warning: This is *not perfect*; you can still get some false negatives. For example:

    # Intermittant and very slow... This often times out, but sometimes does resolve!
    UriResolver.resolve_status "bet-and-win.gr"  # => :maybe_resolves

    # This IS a real website, but (currently) has "Bandwidth Limit Exceeded" error:
    UriResolver.resolve_status "notarealwebsite.com" # => :does_not_resolve

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tom-lord/uri_resolver.

