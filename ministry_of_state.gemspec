# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ministry_of_state}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Hemant Kumar"]
  s.date = %q{2011-10-26}
  s.description = %q{A ActiveRecord plugin for working with state machines}
  s.email = %q{gethemant@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/ministry_of_state.rb",
    "lib/ministry_of_state/ministry_of_state.rb",
    "lib/ministry_of_state/railtie.rb",
    "ministry_of_state.gemspec",
    "test/article.rb",
    "test/blog.rb",
    "test/cargo.rb",
    "test/helper.rb",
    "test/post.rb",
    "test/student.rb",
    "test/test_ministry_of_state.rb",
    "test/user.rb"
  ]
  s.homepage = %q{http://github.com/gnufied/ministry_of_state}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Handling state machines}
  s.test_files = [
    "test/article.rb",
    "test/blog.rb",
    "test/cargo.rb",
    "test/helper.rb",
    "test/post.rb",
    "test/student.rb",
    "test/test_ministry_of_state.rb",
    "test/user.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 3.0.3"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
    else
      s.add_dependency(%q<rails>, [">= 3.0.3"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    end
  else
    s.add_dependency(%q<rails>, [">= 3.0.3"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
  end
end

