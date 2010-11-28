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

## LICENSE

MIT
