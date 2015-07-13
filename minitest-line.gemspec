Gem::Specification.new "minitest-line", "0.6.3" do |s|
  s.description = s.summary  = "Focused tests for Minitest"
  s.email    = "judofyr@gmail.com"
  s.homepage = "https://github.com/judofyr/minitest-line"
  s.authors  = ['Magnus Holm']
  s.license  = "MIT"
  s.files    = Dir['lib/**/*.rb']
  s.add_runtime_dependency('minitest', '~> 5.0')
end
