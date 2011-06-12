# template.rb

#---------------------------------------------------------------------------
#defaults
#---------------------------------------------------------------------------
jquery_flag = true
mongoid_flag = false
heroku_flag = false
haml_flag = false
rspec_flag = false
nested_form_flag = false

#Configure
if yes?('Would you like to use jQuery instead of Prototype? (yes/no)')
  jquery_flag = true
else
  jquery_flag = false
end

if yes?('Do you want to install the Heroku gem so you can deploy to Heroku? (yes/no)')
  heroku_flag = true
else
  heroku_flag = false
end

if yes?('Would you like to use RSpec instead of Test? (yes/no)')
   rspec_flag = true
else
   rspec_flag = false
end

if yes?('Would you like to use nested form? (yes/no)')
   nested_form_flag = true
else
   nested_form_flag = false
end

#----------------------------------------------------------------------------
# Set up git
#----------------------------------------------------------------------------
puts "setting up source control with 'git'..."
# specific to Mac OS X
append_file '.gitignore' do <<-FILE
.DS_Store
doc/api
doc/app
*.swp
*~
FILE
end
git :init
git :add => '.'
git :commit => "-m 'Initial commit of unmodified new Rails app'"

#----------------------------------------------------------------------------
# Remove the usual cruft
#----------------------------------------------------------------------------
puts "removing unneeded files..."
run 'git rm public/index.html'
run 'git rm public/favicon.ico'
run 'git rm public/images/rails.png'
run 'rm README'
run 'touch README'

puts "banning spiders from your site by changing robots.txt..."
gsub_file 'public/robots.txt', /# User-Agent/, 'User-Agent'
gsub_file 'public/robots.txt', /# Disallow/, 'Disallow'

if rspec_flag
  puts "removing unneeded test directory"
  run 'git rm -rf test'
end

puts "setting up the Gemfile..."
run 'rm Gemfile'
create_file 'Gemfile', "source 'http://rubygems.org'\n"
gem 'rails', '3.0.7'
gem 'nifty-generators'
gem "mocha", :group => :test


if !mongoid_flag
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'friendly_id', '3.2.1'
end

#---------------------------------------------------------------------------
# jQuery Option
#----------------------------------------------------------------------------
if jquery_flag
  puts "setting up Gemfile for jQuery..."
  gem 'jquery-rails', '0.2.7'
end


#----------------------------------------------------------------------------
# Haml Option
#----------------------------------------------------------------------------
if haml_flag
  puts "setting up Gemfile for Haml..."
  append_file 'Gemfile', "\n# Bundle gems needed for Haml\n"
  gem 'haml', '3.0.25'
  gem 'haml-rails', '0.3.4', :group => :development
  # the following gems are used to generate Devise views for Haml
  gem 'hpricot', '0.8.3', :group => :development
  gem 'ruby_parser', '2.0.5', :group => :development
end

#--------------------------------------------------------------------------
# RSpec option
#--------------------------------------------------------------------------
if rspec_flag
   gem 'rspec-rails', '2.0.1' , :group => :development
   gem 'rspec-rails', '2.0.1' , :group => :test
   gem 'webrat', '0.7.1' , :group => :test
end


#----------------------------------------------------------------------------
# Heroku Option
#----------------------------------------------------------------------------
if heroku_flag
  puts "adding Heroku gem to the Gemfile..."
  gem 'heroku', '1.17.13', :group => :development
end

if nested_form_flag
  puts "adding nested_form gem to the Gemfile..."
  gem 'nested_form'
end
puts "installing gems (takes a few minutes!)..."
run 'bundle install'


#----------------------------------------------------------------------------
# Set up jQuery
#----------------------------------------------------------------------------
if jquery_flag
  run 'git rm public/javascripts/rails.js'
  puts "replacing Prototype with jQuery"
  # "--ui" enables optional jQuery UI
  run 'rails generate jquery:install --ui'
  # remove the unnecessary files
  run "git rm public/javascripts/controls.js"
  run "git rm public/javascripts/dragdrop.js"
  run "git rm public/javascripts/effects.js"
  run "git rm public/javascripts/prototype.js"
end

if nested_form_flag
   run 'rails g nested_form:install'
   puts  "include nested_form.js after javascript_include_tag :defaults"
   gsub_file 'app/views/layouts/application.html.erb', /:defaults/, ':defaults, "nested_form" '
end

puts "prevent logging of passwords"
gsub_file 'config/application.rb', /:password/, ':password, :password_confirmation' 

#---------------------------------------------------------------------------
#Set up the actual App
#---------------------------------------------------------------------------
#generate(:scaffold, "Post name:string title:string content:text")
#generate(:model, "Comment commenter:string body:text post:references")
#route "root :to => 'posts#index'"
#rake("db:migrate")

#---------------------------------------------------------------------------
#Populating Database
#---------------------------------------------------------------------------
#puts "creating default project database"
#append_file 'db/seeds.rb' do <<-FILE
#puts 'SETTING UP EXAMPLE PEOPLE'
#person1 = Person.create! :name => 'John Doe'
#puts 'New Person created: ' << person1.name
#person2 = Person.create! :name => 'Bob Wilma'
#puts 'New Person created: ' << person2.name
#person3 = Person.create! :name => 'Fred Williams'
#puts 'New Person created: ' << person3.name
#FILE
#end
#run 'rake db:seed'

#----------------------------------------------------------------------------
# Finish up
#----------------------------------------------------------------------------
puts "checking everything into git..."
git :add => '.'
git :commit => "-m 'modified Rails app to use selected options'"

puts "Done setting up Starter Rails app Start building your app now."

