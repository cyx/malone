require File.expand_path("helper", File.dirname(__FILE__))
require File.expand_path("../lib/malone/sandbox", File.dirname(__FILE__))

test "deliveries" do
  Malone.deliver from: "me@me.com", to: "you@me.com",
                 body: "FooBar", subject: "Hello World"

  assert_equal 1, Malone.deliveries.size

  envelope = Malone.deliveries.first

  assert_equal "me@me.com", envelope.from
  assert_equal "you@me.com", envelope.to
  assert_equal "FooBar", envelope.body
  assert_equal "Hello World", envelope.subject
end