Gem::Specification.new do |s|
  s.name = 'malone'
  s.version = "1.2.0"
  s.summary = %{The Mailman}
  s.description = %{Dead-simple Ruby mailing solution which always delivers.}
  s.date = "2011-01-10"
  s.author = "Cyril David"
  s.email = "cyx@cyx.is"
  s.homepage = "http://github.com/cyx/malone"
  s.files = `git ls-files`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency "kuvert", "~> 0.0"
  s.add_development_dependency "cutest", "~> 1.2"
  s.license = "MIT"
end
