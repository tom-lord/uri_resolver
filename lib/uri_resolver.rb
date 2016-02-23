require "uri_resolver/version"
require 'httparty'

module UriResolver
  module Status
    # Closest thing ruby has to an Enum....
    Resolves = :resolves
    MaybeResolves = :maybe_resolves
    DoesNotResolve = :does_not_resolve
  end

  ConnectionFailed = Class.new(StandardError)
  include HTTParty
  default_timeout 1 # HTTParty

  def self.resolve_status(uri)
    # TODO: I used to use code like this, when the below was inside a class:
    #@@responses[uri] ||= try_get_uri(uri) # Might raise error, if DNS error/timeout
    # Is it safe/sensible to memoize the reponses here, for performance?

    response = try_get_uri(uri) # Might raise error, if DNS error/timeout
    case
      # TODO: .dev domains behave differently on Ubuntu vs Windows!!
    when response.code != 200 || response.headers['server'] == "Apache/2.4.7 (Ubuntu)"
      Status::DoesNotResolve
    else
      # TODO: Is it posible to analyse anything further?
      # E.g. does the web page redirect? Does it contain certain strings? Is it at least a minimum size? ....
      Status::Resolves
    end

  rescue SocketError # from TCPSocket#new
    Status::DoesNotResolve
  rescue Net::OpenTimeout # from HTTParty#get
    Status::DoesNotResolve
  rescue Net::ReadTimeout # from HTTParty#get
    Status::DoesNotResolve
  rescue Errno::ECONNREFUSED # From HTTParty#get
    Status::DoesNotResolve
  rescue Errno::ECONNRESET # From HTTParty#get
    Status::DoesNotResolve
  rescue ConnectionFailed # From TCPSocket#new or HTTParty#get -- something funny happened, check manually!
    Status::MaybeResolves
  rescue OpenSSL::SSL::SSLError # Resolves, but SSL certificate is not set up correctly
    Status::Resolves
  rescue URI::InvalidURIError # Resolves, but to weird URL (contains escape sequences??)
    Status::Resolves
  rescue HTTParty::RedirectionTooDeep # Resolves, but with lots of redirection!
    Status::Resolves
  rescue StandardError => e # Something else happened??!!
    warn "URI #{uri} did not resolve, for unknown reason:"
    warn e.message
    Status::MaybeResolves
  end

  private

  def self.try_get_uri(uri, timeout = 1)
    thread_with_timeout(timeout) { TCPSocket.new(uri, 80) }
    # TODO: Do not prepend with "http://" if inappropriate
    thread_with_timeout(timeout*5) { HTTParty.get("http://#{uri}") } # This can take longer...
  end

  def self.thread_with_timeout(timeout)
    th = Thread.new { yield }
    th.priority = 2 # Make sure this runs immediately

    # Do not use Timeout::timeout, as this does not play nicely with multi-threading
    start = Time.now
    loop do
      if th.alive?
        if (Time.now - start > timeout)
          Thread.kill(th)
          raise ConnectionFailed
        end
      else
        return th.value
      end
      sleep 0.1 # Prevent system hammering
    end
  end

end

