require "uri"
require "cgi"

class Malone
  def self.uri=(uri)
    configure(extract_options(uri))
  end

  def self.config
    if not defined?(@config) and ENV["MALONE_URL"]
      self.uri = ENV["MALONE_URL"]
    end

    @config
  end

protected
  def self.extract_options(uri)
    u = URI.parse(uri)
    opts = parse_query(u.query)

    { user: escaped(u.user), pass: escaped(u.password),
      host: u.host, port: u.port.to_i, domain: opts["domain"],
      tls:  bool(opts["tls"]), auth: symbol(opts["auth"]) }
  end

  def self.parse_query(query)
    Hash[query.split("&").map { |kv| kv.split("=") }]
  end

  def self.escaped(val)
    return if val.to_s.empty?

    CGI.unescape(val)
  end

  def self.bool(val)
    return if val.to_s.empty?

    case val
    when "true"  then true
    when "false" then false
    end
  end

  def self.symbol(val)
    return if val.to_s.empty?

    val.to_sym
  end
end