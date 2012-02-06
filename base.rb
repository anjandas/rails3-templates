puts "Removing the extra files"
run "rm public/index.html"
run 'rm public/favicon.ico'
run 'rm public/images/rails.png'
run 'rm README'
run 'touch README'
 
puts "Banning spiders from your site by changing robots.txt..."
gsub_file 'public/robots.txt', /# User-Agent/, 'User-Agent'
gsub_file 'public/robots.txt', /# Disallow/, 'Disallow'
      
puts "Adding files to .gitignore"
run 'cp config/database.yml config/database.example'
append_file '.gitignore' do 
<<-FILE
config/database.yml
.DS_Store
doc/api
doc/app
*.swp
*~
FILE
end

git :init
git :add => '.'
git :commit => "-m 'Initial commit of unmodified rails app'"

if yes?('Do you want to use Haml in place of Erb?(YES/NO)')
  gem "haml-rails"

  gem_group :development do
    gem "hpricot"
    gem "ruby_parser"
  end
end

gem_group :development, :test do
  gem "rspec-rails"
  gem "cucumber-rails"
  gem "webrat"
end

gem "simple_form"

if yes?('Do you want to deploy to Heroku? (YES/NO)')
  gem "heroku"
  gem_group :production do
    gem "pg"
    gem "thin"
  end
end

run "bundle install --without production"
generate("rspec:install")
generate("cucumber:install")
