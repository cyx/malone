Originally taken from my initial draft [here][blogpost].

[blogpost]: http://www.pipetodevnull.com/past/2010/11/27/simple_mailer/

## USAGE

```ruby
$ gem install malone

require "malone"

# typically you would do this somewhere in the bootstrapping
# part of your application

m = Malone.connect(url: "smtp://foo%40bar.com:pass1234@smtp.gmail.com:587",
                   domain: "mysite.com")

m.deliver(from: "me@me.com", to: "you@me.com",
          subject: "Test subject", text: "Great!")

# Malone.current will now remember the last configuration you setup.
Malone.current.config == m.config

# Also starting with Malone 1.0, you can also pass in :html
# for multipart emails.

m.deliver(from: "me@me.com", to: "you@me.com",
          subject: "Test subject",
          text: "Great!", html: "<b>Great!</b>")

```

That's it!

## TESTING

```ruby
require "malone/sandbox"

m = Malone.connect(url: "smtp://foo%40bar.com:pass1234@smtp.gmail.com:587",
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
```

## LICENSE

MIT
