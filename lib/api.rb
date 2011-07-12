require 'http'
require 'digest'

class Api
  attr_accessor :retries
  attr_reader :slug

  def initialize
    @retries = 0
  end

  def endpoint
    "http://0.0.0.0:8888#{slug}"
  end

  def no_more_retries?
    retries > 2
  end

  def get
    @retries += 1
    return_with_error if no_more_retries?

    handle_response(http_client.get(endpoint))
  end
end

class Auth < Api
  def initialize
    super
    @slug = "/auth"
  end

  def self.get_token
    new.token
  end

  def token
    @token ||= begin
      handle_response(http_client.get(endpoint))
    end
  end

  def return_with_error
    raise StandardError.new "The server is not able to authenticate right now"
  end

  private

  def http_client
    HTTP
  end

  def handle_response(resp)
    if resp&.status == 200
      resp.headers["Badsec-Authentication-Token"]
    else
      get
    end
  end
end

class Users < Api
  attr_reader :checksum

  def initialize(auth_token)
    super()
    @slug = "/users"
    @checksum = Digest::SHA256.hexdigest(auth_token + slug)
  end

  def self.get_list(*args)
    new(*args).formatted_list
  end

  def formatted_list
    list.first.split("\n")
  end

  def list
    @list ||= begin
      handle_response(http_client.get(endpoint))
    end
  end

  def return_with_error
    raise StandardError.new "The server is not able to return a users list right now"
  end

  private

  def http_client
    @http_client ||= HTTP.headers({ "X-Request-Checksum": checksum })
  end

  def handle_response(resp)
    if resp&.status == 200
      resp.body
    else
      get
    end
  end
end
