require File.expand_path("helper", File.dirname(__FILE__))
require File.expand_path("../lib/malone/uri", File.dirname(__FILE__))

prepare do
  ENV["MALONE_URL"] = nil
  Malone.send :remove_instance_variable, :@config if Malone.config
end

test "gmail-like attributes" do
  Malone.uri = "smtp://a%40a.com:password@smtp.gmail.com:587" +
               "?domain=example.com&tls=true&auth=login"

  c = Malone.config

  assert_equal "smtp.gmail.com", c.host
  assert_equal "a@a.com", c.user
  assert_equal "password", c.pass
  assert_equal "example.com", c.domain
  assert_equal 587, c.port
  assert_equal true, c.tls
  assert_equal :login, c.auth
end

test "super-simple localhost:25 style attributes" do
  Malone.uri = "smtp://localhost:25?domain=example.com"

  c = Malone.config

  assert_equal "localhost", c.host
  assert_equal 25, c.port
  assert_equal "example.com", c.domain

  assert_equal nil, c.user
  assert_equal nil, c.pass
  assert_equal nil, c.tls
  assert_equal nil, c.auth
end

test "MALONE_URL env var default" do
  assert_equal nil, Malone.config

  ENV["MALONE_URL"] = "smtp://localhost:25?domain=example.com"

  c = Malone.config

  assert_equal "localhost", c.host
  assert_equal 25, c.port
  assert_equal "example.com", c.domain

  assert_equal nil, c.user
  assert_equal nil, c.pass
  assert_equal nil, c.tls
  assert_equal nil, c.auth
end