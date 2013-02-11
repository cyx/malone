require_relative "helper"

test "basic configuration" do
  m = Malone.connect(host: "smtp.gmail.com", port: 587,
                     user: "foo@bar.com", password: "pass1234",
                     domain: "foo.com", auth: "login")

  c = m.config

  assert_equal "smtp.gmail.com", c.host
  assert_equal 587, c.port
  assert_equal "foo@bar.com", c.user
  assert_equal "pass1234", c.password
  assert_equal "foo.com", c.domain
  assert_equal :login, c.auth
end

test "configuration via url" do
  m = Malone.connect(url: "smtp://foo%40bar.com:pass1234@smtp.gmail.com:587")

  c = m.config

  assert_equal "smtp.gmail.com", c.host
  assert_equal 587, c.port
  assert_equal "foo@bar.com", c.user
  assert_equal "pass1234", c.password
end

test "configuration via url and params" do
  m = Malone.connect(url: "smtp://foo%40bar.com:pass1234@smtp.gmail.com:587",
                     domain: "foo.com", auth: "login", password: "barbaz123")

  c = m.config

  assert_equal "smtp.gmail.com", c.host
  assert_equal 587, c.port
  assert_equal "foo@bar.com", c.user
  assert_equal "foo.com", c.domain
  assert_equal :login, c.auth
  assert_equal true, c.tls

  # We verify that parameters passed takes precedence over the URL.
  assert_equal "barbaz123", c.password
end

test "configuration via MALONE_URL" do
  ENV["MALONE_URL"] = "smtp://foo%40bar.com:pass1234@smtp.gmail.com:587"

  m = Malone.connect(domain: "foo.com", auth: "login", tls: false)
  c = m.config

  assert_equal "smtp.gmail.com", c.host
  assert_equal 587, c.port
  assert_equal "foo@bar.com", c.user
  assert_equal "foo.com", c.domain
  assert_equal :login, c.auth
  assert_equal false, c.tls
end

test "typos in configuration" do
  assert_raise NoMethodError do
    Malone.connect(pass: "pass")
  end
end

test "Malone.connect doesn't mutate the options" do
  ex = nil
  begin
    Malone.connect({}.freeze)
  rescue RuntimeError => ex
  end

  assert_equal nil, ex
end

test "Malone.current" do
  Malone.connect(url: "smtp://foo%40bar.com:pass1234@smtp.gmail.com:587")

  c = Malone.current.config

  assert_equal "smtp.gmail.com", c.host
  assert_equal 587, c.port
  assert_equal "foo@bar.com", c.user
  assert_equal "pass1234", c.password
end

test "#envelope" do
  m = Malone.connect

  mail = m.envelope(to: "recipient@me.com", from: "no-reply@mydomain.com",
                    subject: "SUB", text: "TEXT", html: "<h1>TEXT</h1>",
                    cc: "cc@me.com", bcc: "bcc@me.com")

  assert_equal ["recipient@me.com"], mail.to
  assert_equal ["cc@me.com"], mail.cc
  assert_equal ["bcc@me.com"], mail.bcc
  assert_equal ["no-reply@mydomain.com"], mail.from
  assert_equal ["=?utf-8?Q?SUB?="], mail.subject

  assert_equal "TEXT", mail.instance_variable_get(:@text)
  assert_equal "<h1>TEXT</h1>", mail.instance_variable_get(:@html)
end

scope do
  class FakeSMTP < Struct.new(:host, :port)
    def enable_starttls_auto
      @enable_starttls_auto = true
    end

    def start(domain, user, password, auth)
      @domain, @user, @password, @auth = domain, user, password, auth

      @started = true
    end

    def started?
      defined?(@started)
    end

    def finish
      @finish = true
    end

    def send_message(blob, from, *recipients)
      @blob, @from, @recipients = blob, from, recipients
    end

    def [](key)
      instance_variable_get(:"@#{key}")
    end
  end

  module Net
    def SMTP.new(host, port)
      $smtp = FakeSMTP.new(host, port)
    end
  end

  setup do
    Malone.connect(url: "smtp://foo%40bar.com:pass1234@smtp.gmail.com:587",
                   domain: "mydomain.com", auth: :login)
  end

  test "delivering successfully" do |m|
    m.deliver(to: "recipient@me.com", from: "no-reply@mydomain.com",
              subject: "SUB", text: "TEXT", cc: "cc@me.com", bcc: "bcc@me.com")

    assert_equal "smtp.gmail.com", $smtp.host
    assert_equal 587, $smtp.port

    assert $smtp[:enable_starttls_auto]
    assert_equal "mydomain.com", $smtp[:domain]
    assert_equal "foo@bar.com", $smtp[:user]
    assert_equal "pass1234", $smtp[:password]
    assert_equal :login, $smtp[:auth]


    assert_equal ["recipient@me.com", "cc@me.com", "bcc@me.com"], $smtp[:recipients]
    assert_equal "no-reply@mydomain.com", $smtp[:from]

    assert ! $smtp[:blob].include?("bcc@me.com")

    assert $smtp[:started]
    assert $smtp[:finish]
  end

  test "Malone.deliver forwards to Malone.current" do |m|
    Malone.deliver(to: "recipient@me.com", from: "no-reply@mydomain.com",
                   subject: "SUB", text: "TEXT")

    assert_equal "smtp.gmail.com", $smtp.host
    assert_equal 587, $smtp.port

    assert $smtp[:enable_starttls_auto]
    assert_equal "mydomain.com", $smtp[:domain]
    assert_equal "foo@bar.com", $smtp[:user]
    assert_equal "pass1234", $smtp[:password]
    assert_equal :login, $smtp[:auth]

    assert_equal ["recipient@me.com"], $smtp[:recipients]
    assert_equal "no-reply@mydomain.com", $smtp[:from]

    assert $smtp[:started]
    assert $smtp[:finish]
  end

  test "calls #finish even when it fails during send_message" do |m|
    class FakeSMTP
      def send_message(*args)
        raise
      end
    end

    begin
      m.deliver(to: "recipient@me.com", from: "no-reply@mydomain.com",
                subject: "SUB", text: "TEXT")
    rescue
    end

    assert $smtp[:started]
    assert $smtp[:finish]
  end
end

test "sandbox" do
  require "malone/test"

  m = Malone.connect
  m.deliver(to: "recipient@me.com", from: "no-reply@mydomain.com",
            subject: "SUB", text: "TEXT", html: "<h1>TEXT</h1>")

  assert_equal 1, Malone.deliveries.size

  mail = Malone.deliveries.first

  assert_equal "no-reply@mydomain.com", mail.from
  assert_equal "recipient@me.com", mail.to
  assert_equal "SUB", mail.subject
  assert_equal "TEXT", mail.text
  assert_equal "<h1>TEXT</h1>", mail.html
end
