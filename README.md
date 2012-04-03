malone(1) -- send mail using smtp without any fuss
==================================================

## USAGE

    require "malone"

    # Typically you would do this somewhere in the bootstrapping
    # part of your application

    m = Malone.connect(url: "smtp://foo%40bar.com:pass@smtp.gmail.com:587",
                       domain: "mysite.com")

    m.deliver(from: "me@me.com", to: "you@me.com",
              subject: "Test subject", text: "Great!")

    # Malone.current will now remember the last configuration you setup.
    Malone.current.config == m.config

    # Now you can also do Malone.deliver, which is syntactic sugar
    # for Malone.current.deliver
    Malone.deliver(from: "me@me.com", to: "you@me.com",
                   subject: "Test subject", text: "Great!")

    # Also starting with Malone 1.0, you can pass in :html
    # for multipart emails.

    Malone.deliver(from: "me@me.com", to: "you@me.com",
                   subject: "Test subject",
                   text: "Great!", html: "<b>Great!</b>")


## TESTING

    require "malone/test"

    m = Malone.connect(url: "smtp://foo%40bar.com:pass@smtp.gmail.com:587",
                       domain: "mysite.com")

    m.deliver(from: "me@me.com", to: "you@me.com",
              subject: "Test subject", text: "Great!")

    Malone.deliveries.size == 1
    # => true

    mail = Malone.deliveries.first

    "me@me.com" == mail.from
    # => true

    "you@me.com" == mail.to
    # => true

    "FooBar" == mail.text
    # => true

    "Hello World" == envelope.subject
    # => true

## INSTALLATION

    gem install malone

## CONFIGURATION TIPS

If you're used to doing configuration via environment
variables, similar to how Heroku does configuration, then
you can simply set an environment variable in your
production machine like so:

    export MALONE_URL=smtp://foo%40bar.com:pass@smtp.gmail.com:587

Then you can connect using the environment variable in your
code like so:

    Malone.connect(url: ENV["MALONE_URL"])

    # or quite simply
    Malone.connect

By default Malone tries for the environment variable `MALONE_URL` when
you call `Malone.connect` without any arguments.
