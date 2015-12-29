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
end

environment 'config.action_mailer.delivery_method = :letter_opener', env: 'development'

generate 'devise:install'
generate 'friendly_id'

inject_into_file 'app/assets/javascripts/application.js', "//= require jquery.turbolinks\n", after: "require jquery\n"
inject_into_file 'app/assets/javascripts/application.js', "//= require nprogress\n//= require nprogress-turbolinks\n", after: "require turbolinks\n"
inject_into_file 'app/assets/javascripts/application.js', "//= require holder\n", after: "require nprogress-turbolinks\n"

inject_into_file 'app/assets/stylesheets/application.css', " *= require nprogress\n", after: "*= require_self\n"
inject_into_file 'app/assets/stylesheets/application.css', " *= require nprogress-bootstrap\n", after: "*= require nprogress\n"

inject_into_file 'config/environments/development.rb', after: "class Application < Rails::Application \n" do <<-'RUBY'
    config.after_initialize do
      Bullet.enable = true
      Bullet.alert = true
      Bullet.rails_logger = true
      Bullet.console = true
    end
  RUBY
end

after_bundle do
  git :init
end