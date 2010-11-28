Gem::Specification.new do |s|
  s.name = 'malone'
  s.version = "0.0.1"
  s.summary = %{Dead-simple Ruby mailing solution that always delivers.}
  s.date = "2010-11-28"
  s.author = "Cyril David"
  s.email = "cyx@pipetodevnull.com"
  s.homepage = "http://github.com/cyx/malone"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.files = ["lib/malone.rb", "README.markdown", "LICENSE", "test/helper.rb", "test/malone_test.rb"]

  s.require_paths = ['lib']

  s.add_dependency "mailfactory"
  s.add_development_dependency "cutest"
  s.add_development_dependency "flexmock"
  s.has_rdoc = false
end
