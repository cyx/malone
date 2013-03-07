Gem::Specification.new do |s|
  s.name = 'malone'
  s.version = "1.0.4"
  s.summary = %{Dead-simple Ruby mailing solution which always delivers.}
  s.date = "2011-01-10"
  s.author = "Cyril David"
  s.email = "me@cyrildavid.com"
  s.homepage = "http://github.com/cyx/malone"

  s.files = Dir[
    "CHANGELOG",
    "LICENSE",
    "README.md",
    "lib/**/*.rb",
    "test/*.*",
    "*.gemspec"
  ]

  s.require_paths = ["lib"]

  s.add_dependency "mailfactory", "~> 1.4"
  s.add_development_dependency "cutest"
end
