require "cgi"
require "kuvert"
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

  def self.deliver(dict)
    current.deliver(dict)
  end

  def initialize(config)
    @config = config
  end

  def deliver(dict)
    mail = envelope(dict)
    yield mail if block_given?

    smtp = Net::SMTP.new(config.host, config.port)
    smtp.enable_starttls_auto if config.tls

    begin
      smtp.start(config.domain, config.user, config.password, config.auth)
      smtp.send_message(mail.to_s, mail.from.first, *mail.recipients)
    ensure
      smtp.finish if smtp.started?
    end
  end

  def envelope(dict)
    envelope = Kuvert.new
    envelope.from    = dict[:from]
    envelope.to      = dict[:to]
    envelope.replyto = dict[:replyto]
    envelope.cc      = dict[:cc] if dict[:cc]
    envelope.bcc     = dict[:bcc] if dict[:bcc]
    envelope.text    = dict[:text]
    envelope.rawhtml = dict[:html] if dict[:html]
    envelope.subject = dict[:subject]

    envelope.attach(dict[:attach]) if dict[:attach]
    envelope.add_attachment_as(*dict[:attach_as]) if dict[:attach_as]

    return envelope
  end

  class Configuration
    attr_accessor :host
    attr_accessor :port
    attr_accessor :user
    attr_accessor :password
    attr_accessor :domain
    attr_accessor :tls
    
    attr :auth

    def initialize(options)
      opts = options.dup

      @tls = true

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
      @auth = val && val.to_sym
    end

  private
    def unescaped(val)
      return if val.to_s.empty?

      CGI.unescape(val)
    end
  end
end
