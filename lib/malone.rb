require "cgi"
require "mailfactory"
require "net/smtp"
require "uri"

class Malone
  attr :config

  def self.connect(options = {})
    @config = Configuration.new(options)

    current
  end

  def self.current
    unless defined?(@config)
      raise RuntimeError, "Missing configuration: Try doing `Malone.connect`."
    end

    return new(@config)
  end

  def initialize(config)
    @config = config
  end

  def deliver(dict)
    mail = envelope(dict)

    smtp = Net::SMTP.new(config.host, config.port)
    smtp.enable_starttls_auto

    begin
      smtp.start(config.domain, config.user, config.password, config.auth)
      smtp.send_message(mail.to_s, mail.from.first, mail.to)
    ensure
      smtp.finish if smtp.started?
    end
  end

  def envelope(dict)
    envelope = MailFactory.new
    envelope.from    = dict[:from]
    envelope.to      = dict[:to]
    envelope.text    = dict[:text]
    envelope.rawhtml = dict[:html] if dict[:html]
    envelope.subject = dict[:subject]

    return envelope
  end

  class Configuration
    attr_accessor :host
    attr_accessor :port
    attr_accessor :user
    attr_accessor :password
    attr_accessor :domain
    attr_accessor :auth

    def initialize(options)
      opts = options.dup

      url = opts.delete(:url) || ENV["MALONE_URL"]

      if url
        uri = URI(url)

        opts[:host]     ||= uri.host
        opts[:port]     ||= uri.port.to_i
        opts[:user]     ||= unescaped(uri.user)
        opts[:password] ||= unescaped(uri.password)
      end

      opts.each do |key, val|
        send(:"#{key}=", val)
      end
    end

    def auth=(val)
      @auth = val
      @auth = @auth.to_sym if @auth
    end

  private
    def unescaped(val)
      return if val.to_s.empty?

      CGI.unescape(val)
    end
  end
end
