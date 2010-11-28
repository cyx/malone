require File.expand_path("helper", File.dirname(__FILE__))

setup do
  m = Malone.new(from: "me@me.com", to: "you@me.com",
                 body: "FooBar", subject: "Hello World")
end

test "envelope" do |m|
  assert m.envelope.from == ["me@me.com"]
  assert m.envelope.to   == ["you@me.com"]

  assert m.envelope.instance_variable_get(:@text)    == "FooBar"
  assert m.envelope.get_header("subject") == ["=?utf-8?Q?Hello_World?="]
end

test "delivering with no config" do |m|
  assert_raise Malone::NotConfigured do
    m.deliver
  end
end

test "configuring" do
  Malone.configure(
    host: "smtp.gmail.com",
    port: 587,
    domain: "mydomain.com",
    tls: true,
    user: "me@mydomain.com",
    pass: "mypass",
    auth: :login
  )

  assert Malone.config.host == "smtp.gmail.com"
  assert Malone.config.port == 587
  assert Malone.config.domain == "mydomain.com"
  assert Malone.config.tls  == true
  assert Malone.config.user == "me@mydomain.com"
  assert Malone.config.pass == "mypass"
  assert Malone.config.auth == :login
end

scope do
  setup do
    Malone.configure(
      host: "smtp.gmail.com",
      port: 587,
      domain: "mydomain.com",
      tls: true,
      user: "me@mydomain.com",
      pass: "mypass",
      auth: :login
    )
  end
  
  test "delivering successfully" do
    malone = Malone.new(to: "you@me.com", from: "me@me.com",
                        subject: "My subject", body: "My body")
  
    # Let's begin the mocking fun
    sender = flexmock("smtp sender")
  
    # We start out by capturing the Net::SMTP.new part
    flexmock(Net::SMTP).should_receive(:new).with(
      "smtp.gmail.com", 587
    ).and_return(sender)
  
    # Since we configured it with tls: true, then enable_starttls 
    # should be called
    sender.should_receive(:enable_starttls).once
  
    # Now we verify that start was indeed called exactly with the arguments
    # we passed in
    sender.should_receive(:start).once.with(
      "mydomain.com", "me@mydomain.com", "mypass", :login, 
    )

    # This is a bit of a hack, since envelope.to_s changes everytime.
    # Specifically, The Message-ID part changes.
    envelope_to_s = malone.envelope.to_s
    
    # So we get one result of envelope.to_s
    flexmock(malone.envelope).should_receive(:to_s).and_return(envelope_to_s)
  
    # And then we make sure that that value of envelope.to_s is used
    # instead of making it generate a new Message-ID
    sender.should_receive(:send_message).once.with(
      envelope_to_s, "me@me.com", ["you@me.com"]
    ).and_return("OK")

    # I think this is important, otherwise the connection to the
    # smtp server won't be closed properly
    sender.should_receive(:finish).once
  
    # One important part of the API of malone is that deliver
    # should return the result of Net::SMTP#send_message.
    assert "OK" == malone.deliver
  end

  test "delivering and failing" do
    malone = Malone.new(to: "you@me.com", from: "me@me.com",
                        subject: "My subject", body: "My body")
  
    # This is more or less the same example as above,
    # except that here we make send_message fail
    # and verify that finish is still called
    sender = flexmock("smtp sender")

    flexmock(Net::SMTP).should_receive(:new).with(
      "smtp.gmail.com", 587
    ).and_return(sender)

    sender.should_receive(:enable_starttls).once

    sender.should_receive(:start).once.with(
      "mydomain.com", "me@mydomain.com", "mypass", :login, 
    )
  
    sender.should_receive(:send_message).once.and_raise(StandardError)
    sender.should_receive(:finish).once
    
    assert_raise StandardError do
      assert nil == malone.deliver
    end
  end
end
