Originally taken from my initial draft [here][blogpost].

[blogpost]: http://www.pipetodevnull.com/past/2010/11/27/simple_mailer/

## USAGE

    $ gem install malone

    require "malone"

    # typically you would do this somewhere in the bootstrapping
    # part of your application

    Malone.configure(
      host:     "smtp.gmail.com",
      port:     587,
      tls:      true,
      domain:   "mydomain.com",
      user:     "me@mydomain.com",
      pass:     "mypass",
      auth:     :login,
      from:     "no-reply@mydomain.com"
    )

    Malone.deliver(from: "me@me.com", to: "you@me.com",
                   subject: "Test subject", body: "Great!")

That's it!

## TESTING

    require "malone/sandbox"

    Malone.deliver(from: "me@me.com", to: "you@me.com",
                   subject: "Test subject", body: "Great!")

    Malone.deliveries.size == 1
    # => true

    envelope = Malone.deliveries.first

    "me@me.com" == envelope.from
    # => true

    "you@me.com" == envelope.to
    # => true

    "FooBar" == envelope.body
    # => true

    "Hello World" == envelope.subject## LICENSE
    # => true

MIT