def say_custom(tag, text); say "\033[1m\033[36m" + tag.to_s.rjust(10) + "\033[0m" + "  #{text}" end

def whisper_ask_wizard(question)
  ask "\033[1m\033[36m" + ("choose").rjust(10) + "\033[0m" + "  #{question}"
end

def multiple_choice(question, choices)
  say_custom('option', "\033[1m\033[36m" + "#{question}\033[0m")
  values = {}
  choices.each_with_index do |choice,i|
    values[(i + 1).to_s] = choice[1]
    say_custom( (i + 1).to_s + ')', choice[0] )
  end
  answer = whisper_ask_wizard("Enter your selection:") while !values.keys.include?(answer)
  values[answer]
end

gsub_file 'Gemfile', /gem 'sqlite3'\n/, ''

database_adapter = multiple_choice "Database used in development?", [["PostgreSQL", "postgresql"], ["MySQL", "mysql"]]

if database_adapter == "postgresql"
  gem 'pg'
  gem 'pg_search'
else
  gem 'mysql2'
end

gem 'devise'
gem 'devise-async'
gem 'mini_magick'
gem 'carrierwave'
gem 'carrierwave_backgrounder'
gem 'kaminari'
gem 'bootstrap-sass', '~> 3.3.6'
gem 'bootstrap-kaminari-views'
gem 'slim-rails'
gem 'nprogress-rails'
gem 'exception_notification'
gem 'dotenv-rails'
gem 'sidekiq'
gem 'redis-namespace'
gem 'redis-rails'
gem 'jquery-turbolinks'
gem 'friendly_id', '~> 5.1.0'

gem_group :development do
  gem 'thin'
  gem 'byebug'
  gem 'foreman'
  gem 'pry-byebug'
  gem 'letter_opener_web', '~> 1.2.0'
  gem 'rspec-rails'
  gem 'rails_best_practices'
  gem 'lol_dba'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'annotate', github: 'ctran/annotate_models'
  gem 'rack-mini-profiler', require: false
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'meta_request'
  gem 'awesome_print'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano3-puma', github: "seuros/capistrano-puma"
end

application(nil, env: "development") do<<-'RUBY'
config.action_mailer.delivery_method = :letter_opener
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.rails_logger = true
    Bullet.console = true
  end
RUBY
end

create_file 'Procfile', "web: bundle exec rails server \nsidekiq: bundle exec sidekiq" 

create_file "app/assets/stylesheets/bootstrap_modified.scss" do<<-'SCSS'
@import "bootstrap-sprockets";
@import "bootstrap";
body { padding-top: 70px; }
SCSS
end

create_file "app/assets/stylesheets/npprogress-custom.scss" do<<-'SCSS'
// custom loader color
$nprogress-color: #fff;

@import 'nprogress';
@import 'nprogress-bootstrap';
SCSS
end

create_file '.env' do <<-FILE
# Add account credentials and API keys here.
# This file should be listed in .gitignore to keep your settings secret!
# Each entry sets a local environment variable.
# For example, setting:
# GMAIL_USERNAME=Your_Gmail_Username
# makes 'Your_Gmail_Username' available as ENV["GMAIL_USERNAME"]
FILE
end

inject_into_file 'app/assets/javascripts/application.js', "//= require jquery.turbolinks\n", after: "require jquery\n"
inject_into_file 'app/assets/javascripts/application.js', after: "require turbolinks\n" do
  "//= require nprogress\n//= require nprogress-turbolinks\n//= require holder\n" 
end

inject_into_file 'app/assets/stylesheets/application.css', after: "*= require_self\n" do
  " *= require bootstrap_modified\n  *= require npprogress-custom\n"
end

append_file ".gitignore" do<<-FILE
/config/database.yml
public/uploads
FILE
end

after_bundle do
  git :init
  generate 'devise:install'
  generate 'friendly_id'
end