Gem::Specification.new do |s|
  s.name                  = 'hierarchy-tree'
  s.version               = '0.1.1'
  s.platform              = Gem::Platform::RUBY
  s.authors               = ['Victor Cordeiro Costa']
  s.email                 = ['victorcorcos@gmail.com']
  s.description           = %q{hierarchy-tree is a gem that shows the whole hierarchy
                               and the associations related to a desired class.}
  s.homepage              = 'https://github.com/Victorcorcos/hierarchy-tree'
  s.summary               = %q{hierarchy-tree is a gem that shows the whole hierarchy
                               and the associations related to a desired class.}
  s.files                 = ['lib/hierarchy_tree.rb']
  s.require_paths         = ['lib']
  s.required_ruby_version = '>= 2.0'
  s.license               = 'MIT'

  s.add_development_dependency 'minitest', '~> 5.10'
  s.add_development_dependency 'rake', '~> 12.1'
  s.add_dependency 'activerecord', '>=4.2'
end
