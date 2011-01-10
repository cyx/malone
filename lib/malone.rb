require "net/smtp"
require "ostruct"
require "mailfactory"

class Malone
  VERSION = "0.0.2"

  attr :envelope

  def self.deliver(params = {})
    new(params).deliver
  end
  
  def self.configure(hash)
    @config = OpenStruct.new(hash)
  end

  def self.config
    @config
  end

  def initialize(params = {})
    @envelope = MailFactory.new
    @envelope.from    = params[:from]
    @envelope.to      = params[:to]
    @envelope.text    = params[:body]
    @envelope.subject = params[:subject]
  end

  def deliver
    smtp = Net::SMTP.new config.host, config.port
    smtp.enable_starttls if config.tls
    
    begin
      smtp.start(config.domain, config.user, config.pass, config.auth)
      smtp.send_message(envelope.to_s, envelope.from.first, envelope.to)
    ensure
      smtp.finish
    end
  end

private
  NotConfigured = Class.new(StandardError)

  def config
    self.class.config or raise(NotConfigured)
  end
end
