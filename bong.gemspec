
Gem::Specification.new do |s|
  s.name = %q{bong}
  s.version = "0.0.2"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Geoffrey Grosenbach"]
  s.date = %q{2008-05-19}
  s.default_executable = %q{bong}
  s.description = %q{== DESCRIPTION:  Hit your website with bong. Uses httperf to run a suite of benchmarking tests against specified urls on your site.   Graphical output and multi-test comparisons are planned. Apache ab support may be added in the future.}
  s.email = %q{boss@topfunky.com}
  s.executables = ["bong"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/bong", "lib/bong.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://rubyforge.org/projects/bong}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{bong}
  s.rubygems_version = %q{1.1.1}
  s.summary = %q{Website benchmarking helper.}

  s.add_dependency(%q<hoe>, [">= 1.5.1"])
end
