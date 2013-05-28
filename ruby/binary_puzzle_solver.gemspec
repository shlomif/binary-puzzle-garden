# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "binary_puzzle_solver/version"

Gem::Specification.new do |s|
    s.name        = "binary_puzzle_solver"
    s.version     = Binary_Puzzle_Solver::VERSION
    s.executables << 'binary-puzzle-solve'
    s.platform    = Gem::Platform::RUBY
    s.authors     = ["Shlomi Fish"]
    s.email       = ["shlomif@cpan.org"]
    # TODO : add a better home page on http://www.shlomifish.org/ .
    s.homepage    = "http://www.shlomifish.org/open-source/projects/japanese-puzzle-games/binary-puzzle/"
    s.summary     = %q{A solver for http://www.binarypuzzle.com/ instances}
    s.description = %q{This is a solver for instances of the so-called Binary
      Puzzle from http://www.binarypuzzle.com/ . It is incomplete, but
      can still solve some games
    }

    s.add_runtime_dependency "launchy"
    s.add_development_dependency "rspec", "~>2.5.0"

    s.files         = `git ls-files -- .`.split("\n")
    s.test_files    = `git ls-files -- ./{test,spec,features}/*`.split("\n")
    s.executables   = `git ls-files -- ./bin/*`.split("\n").map{ |f| File.basename(f) }
    s.require_paths = ["lib"]
end
