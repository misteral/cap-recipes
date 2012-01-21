Gem::Specification.new do |s|
  s.name = %q{cap-recipes}
  s.version = "2.0.1"

  s.authors = ["Donovan Bray","Nathan Esquenazi"]
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.description = %q{Battle-tested capistrano recipes for debian, passenger, apache, delayed_job, juggernaut, rubygems, backgroundrb, rails and more}
  s.email = %w{donnoman@donovanbray.com nesquena@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.textile"
  ]
  s.files         = `git ls-files`.split("\n")
  s.homepage = %q{http://github.com/donnoman/cap-recipes}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{cap-recipes}
  s.rubygems_version = %q{1.7.2}
  s.summary = %q{Battle-tested capistrano recipes for passenger, delayed_job, and more}
end
