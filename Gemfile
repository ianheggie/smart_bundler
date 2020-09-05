source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in smarter_bundler.gemspec
gemspec

# Adjustments here

gem "bundler", (RUBY_VERSION >= '2.3.0' ? '> 1.3' : '~> 1.3')
if RUBY_VERSION < '2.3'
  gem 'psych', '< 3.0'
elsif RUBY_VERSION < '2.4'
  gem 'psych', '3.1.0'
end

