require 'rubygems'

require 'hoe'
require './lib/bong.rb'

Hoe.new('bong', Bong::VERSION) do |p|
  p.rubyforge_name = 'bong'
  p.author = 'Geoffrey Grosenbach'
  p.email = 'boss@topfunky.com'
  p.summary = 'Website benchmarking helper.'
  p.description = p.paragraphs_of('README.txt', 1..2).join("\n\n")
  p.url = "http://rubyforge.org/projects/bong"
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")

  p.remote_rdoc_dir = '' # Release to root
end
