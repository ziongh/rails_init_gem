class NewGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  class_option :lastest_gems, :type => :boolean, :default => true, :desc => "Include latest gems."
  $oi = source_root


  def gemfile_update
    project_name = Rails.application.class.parent_name
    project_path = Rails.root
    project_user = ENV['USER']

    
# --------------------------------------------
    remove_file "Gemfile"
    create_file 'Gemfile' do
    <<-GEMFILE
        source 'https://rubygems.org'

        # Basic needs
        gem 'rails'
        gem "pg"
        gem 'sqlite3'
        gem 'rails_init_gem'
        gem 'sass-rails'
        gem 'coffee-rails'
        gem 'jbuilder'
        gem 'jquery-rails'

        # Speedup gems
        gem 'uglifier'
        gem 'turbolinks'
        gem 'rails_serve_static_assets'
        gem 'multi_fetch_fragments'
        gem 'therubyracer'
        gem 'htmlcompressor'

        # Preitify gems
        gem 'bootstrap-sass'
        gem 'chosen-rails'
        gem 'country_select'
        gem 'friendly_id'
        gem 'high_voltage'

        # Security and Authentication gems
        gem 'cancan'
        gem 'devise', git: 'https://github.com/plataformatec/devise.git'
        gem 'devise-encryptable'
        gem 'devise_invitable'
        gem 'devise-i18n'
        gem 'devise-guests'
        gem 'rolify'

        # Forms Gem
        gem 'simple_form', git: 'https://github.com/plataformatec/simple_form.git'

        # Pagination Gem
        gem 'will_paginate'
        gem 'will_paginate-bootstrap'

        # Cache Gem
        gem 'redis-rails'
        gem 'redis-namespace'

        # Full-Text Search Gem
        gem 'elasticsearch-model'
        gem 'elasticsearch-rails'

        # Jobs Gems
        gem 'whenever'
        gem "resque"

        # Payment
        gem 'activemerchant'
        gem 'paypal-sdk-rest'

        # Email
        gem 'mandrill-api'
        gem 'mandrill_mailer'


        group :development do
            # gem 'sqlite3'
            gem 'better_errors'
            gem 'binding_of_caller'
            gem 'capistrano'
            gem 'capistrano-bundler'
            gem 'capistrano-rails'
            gem 'capistrano-rails-console'
            gem 'capistrano-rvm'
            gem 'guard-bundler'
            gem 'guard-rails'
            gem 'guard-rspec'
            gem 'quiet_assets'
            gem 'rails_layout'
            # gem 'active_reload'
            gem 'annotate'
        end
        group :development, :test do
            gem 'factory_girl_rails'
            gem 'pry-rails'
            gem 'pry-rescue'
            gem 'pry-stack_explorer'
            gem 'rspec-rails'
        end
        group :production do
            gem 'unicorn'
            gem 'yui-compressor'
        end
        group :test do
            gem 'capybara'
            gem 'database_cleaner'
            gem 'email_spec'
            gem 'colored'
            gem 'deadweight', :require => 'deadweight/hijack/rails'
        end
    GEMFILE
    end
    inside Rails.root do
      run "bundle install"
    end
# --------------------------------------------

    # Drop Database
    rake("db:drop")
    rake("db:create")

    # Install Annotate to facilitate development of Models
    generate "annotate:install"

    # Install JQuery
    generate "jquery:install"

    # Install Simple_Form with Bootstrap
    generate "simple_form:install --bootstrap"

    # Pre configure Bootstrap
    generate "layout:install"

    # Use Friendly ID to hide ID field from URLs
    generate "friendly_id"

    # Create Some Static Pages
    generate "controller StaticPages home help about contact"

    # Migrate DB
    rake("db:migrate")

    # Install Devise to manage Users
    generate "devise:install"

    # Add functionality to invite Friends
    generate "devise_invitable:install"

    # Add Necessary views to Users
    generate "devise:views"

    # Install Paypal System on the Project
    generate "paypal:sdk:install"

    # Install Testing utilities
    generate "rspec:install"

    # Create User Table
    generate "devise User"

    # Migrate DB
    rake("db:migrate")

    # Create Guest User
    generate "devise_guests User"

    # Add CanCan to manage Permissions
    generate "cancan:ability"

    # Add Rolify to Add roles to Users
    generate "rolify Role User"

    # Correct FileName Bug of Rolify
    filename = Dir.glob("db/migrate/*rolify_create_roles")[0]
    copy_file File.join(project_path, filename), filename + ".rb"
    remove_file File.join(project_path, filename)

    # Migrate
    rake("db:migrate")

    # Create Invitable User Table
    generate "devise_invitable User"

    # Migrate
    rake("db:migrate")

    # Create Devise Inviting Pages
    generate "devise_invitable:views"

    # Add Testing tools to test Emails
    generate "email_spec:steps"

    # Add slug to user to Hide ID from URLs
    generate "migration add_slug_to_users slug:string:uniq"

    # Add Some data to User (e.g CPF, CreditCard, Etc..)
    generate "migration add_name_to_users name:string cpf:string cnpj:string"
    generate "migration add_provider_to_users provider:boolean"
    generate "migration add_client_to_users client:boolean"

    # Set field default value to False (they are not clients nor providers at the beginning)
    filename = Dir.glob("db/migrate/*add_client_to_users.rb")[0]
    inject_into_file filename,", default: false",after: "boolean"
    filename = Dir.glob("db/migrate/*add_provider_to_users.rb")[0]
    inject_into_file filename,", default: false",after: "boolean"

    # Migrate
    rake("db:migrate")
    

# -------- Configure Redis (cahce service) -------------------

    copy_file "redis.rb", "config/initializers/redis.rb"
    copy_file "secret_token.rb", "config/initializers/secret_token.rb"
    gsub_file("config/initializers/secret_token.rb", "Ww::Application.config.secret_key_base = secret_token", project_name+"::Application.config.secret_key_base = secret_token")
    copy_file "secret.yml", "config/secrets.yml"
    # copy_file "i18n_backend.rb", "config/initializers/i18n_backend.rb" # Add Translation To Redis Server (quite expensive)
    
# -------- Install Unicorn (WebServer) -------------------
    copy_file "unicorn.rb", "config/unicorn.rb"
    gsub_file("config/unicorn.rb", "Ww", project_name)
    gsub_file("config/unicorn.rb", "root = \"/home/ziongh/railsProjects/current/ww\"", "root = \"#{project_path}\"")
    copy_file "unicorn_init.sh", "config/unicorn_init.sh"
    gsub_file("config/unicorn_init.sh", "APP_ROOT=\"/home/EXAMPLE_USER/railsProjects/current/ww\"", "APP_ROOT=\"#{project_path}\"" )
    gsub_file("config/unicorn_init.sh", "AS_USER=EXAMPLE_USER", "AS_USER=\"#{project_user}\"" )
    
 # ----------- Configure Pages To use Bootstrap -------------   
    inject_into_file "app/assets/stylesheets/application.css.scss", "\n *= require bootstrap
 *= require chosen", after: "*= require_tree ."

 # ----------- Configure Routes ---------------------------------   
    inject_into_file "config/routes.rb", "  match '/contact', to: 'static_pages#contact' , via: 'get'\n", :after => "Rails.application.routes.draw do\n"
    inject_into_file "config/routes.rb", "  match '/about', to: 'static_pages#about' , via: 'get'\n", :after => "Rails.application.routes.draw do\n"
    inject_into_file "config/routes.rb", "  match '/help', to: 'static_pages#help' , via: 'get'\n", :after => "Rails.application.routes.draw do\n"
    inject_into_file "config/routes.rb", "  root to: \"static_pages#home\"\n", :after => "Rails.application.routes.draw do\n"
    
 # ----------- Configure Translations, assets and cache store -----------------------  
    inject_into_file "config/application.rb", "\n  I18n.enforce_available_locales = true\n", :before => "end\nend"
    inject_into_file "config/application.rb", "\n  config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)\n", :before => "end\nend"
    inject_into_file "config/application.rb", "\n  config.assets.initialize_on_precompile = false\n", :before => "end\nend"
    # inject_into_file "config/application.rb", "\n  config.cache_store = :redis_store, 'redis://localhost:6379/0/cache', { expires_in: 90.minutes }\n", :before => "end\nend"
    inject_into_file "config/application.rb", "\n  config.cache_store = :memory_store, { expires_in: 90.minutes }\n", :before => "end\nend"
    inject_into_file "config/application.rb", "\n  config.hosts = {
      \"development\" => \"localhost:3000\",
      \"test\"        => \"localhost:3000\",
      \"production\"  => \"#{project_name}.com\"
    }\n", :before => "end\nend"

# ----------- Configure production properties and mailing system (Mandrill) ----------------------
    inject_into_file "config/environments/production.rb", "  config.static_cache_control = \"public, max-age=3600000\"\n", :after => "pplication.configure do\n"
    inject_into_file "config/environments/production.rb", "  config.assets.css_compressor = :yui\n", :after => "pplication.configure do\n"
    gsub_file("config/environments/production.rb",'config.assets.compile = false','config.assets.compile = true')
    
    inject_into_file "config/environments/production.rb", "\n\n  config.action_mailer.default_url_options = { :host => config.hosts[Rails.env] }
  # ActionMailer Config
  # Setup for production - deliveries, no errors raised
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default :charset => \"utf-8\"

  # Mandrill Connectivity
  config.action_mailer.smtp_settings = {
    :address   => \"smtp.mandrillapp.com\",
    :port      => 587, # ports 587 and 2525 are also supported with STARTTLS
    :enable_starttls_auto => true, # detects and uses STARTTLS
    :user_name => \"example@example.com\",
    :password  => \"PASSWORD_EXAMPLE\", # SMTP password is any valid API key
    :authentication => 'plain', # Mandrill supports 'plain' or 'login'
    :domain => config.hosts[Rails.env]
  }\n\n", :after => "pplication.configure do\n"

    


# ------------- Configure Mailing service for development (testing) -------------------------------    
    inject_into_file "config/environments/development.rb", "\n\n   config.action_mailer.default_url_options = { :host => config.hosts[Rails.env] }
  config.action_mailer.delivery_method = :smtp
  # change to true to allow email to be sent during development
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => \"utf-8\"
\n\n", after: "pplication.configure do\n"

    inject_into_file "config/environments/test.rb", "# ActionMailer Config
  config.action_mailer.default_url_options = { :host => config.hosts[Rails.env] }
\n", before: "end"


# ------------- Configure HTML Compressor ------------------------------- 
    inject_into_file "config/environments/production.rb", "\n  options = {
    :enabled => true,
    :remove_multi_spaces => true,
    :remove_comments => true,
    :remove_intertag_spaces => false,
    :remove_quotes => false,
    :compress_css => false,
    :compress_javascript => false,
    :simple_doctype => false,
    :remove_script_attributes => false,
    :remove_style_attributes => false,
    :remove_link_attributes => false,
    :remove_form_attributes => false,
    :remove_input_attributes => false,
    :remove_javascript_protocol => false,
    :remove_http_protocol => false,
    :remove_https_protocol => false,
    :preserve_line_breaks => false,
    :simple_boolean_attributes => false
  }\n
  config.middleware.use HtmlCompressor::Rack, options", :before => "\nend"

# ------------- Create Secret for APP -------------------------------
    create_file (".secret")
    prepend_file(".secret", %x[rake secret])

# ---------- Configure Simple_form to be fast and compatible ------------------
    # gsub_file("config/initializers/session_store.rb", "Rails.application.config.session_store :cookie_store", "Rails.application.config.session_store :redis_store")
    gsub_file("config/initializers/simple_form.rb", "b.optional :pattern", "#b.optional :pattern")
    gsub_file("config/initializers/simple_form.rb", "# config.collection_wrapper_class = nil", "config.collection_wrapper_class = nil")
    gsub_file("config/initializers/simple_form.rb", "# config.form_class = :simple_form", "config.form_class = nil")
    gsub_file("config/initializers/simple_form.rb", "config.browser_validations = false", "config.browser_validations = true")
    gsub_file("config/initializers/simple_form.rb", "# config.translate_labels = true", "config.translate_labels = true")
    gsub_file("config/initializers/simple_form.rb", "# config.input_class = nil", "config.input_class = nil")
    gsub_file("config/initializers/simple_form.rb", "# config.cache_discovery = !Rails.env.development?", "config.cache_discovery = !Rails.env.development?")

# ----------- Fix Simple_form Integration with Bootstrap---------------------------------
    inject_into_file "config/initializers/simple_form_bootstrap.rb", "\n    # b.use :pattern\n", after:"b.use :placeholder"

# ------------ Change APP Title --------------------------------
    inject_into_file "app/helpers/application_helper.rb", "\n   def title
        base_title = \"#{project_name}\"
        if @title.nil?
            base_title
        else
            \"#\{base_title} | #\{@title}\"
        end
    end
    ", :after => "module ApplicationHelper"

# ------------ Configure Static Pages Title --------------------------------
    inject_into_file "app/controllers/static_pages_controller.rb", "\n    @title = nil\n", after: "def home"
    inject_into_file "app/controllers/static_pages_controller.rb", "\n    @title = \"About\"\n", after: "def about"
    inject_into_file "app/controllers/static_pages_controller.rb", "\n    @title = \"Help\"\n", after: "def help"
    inject_into_file "app/controllers/static_pages_controller.rb", "\n    @title = \"Contact\"\n", after: "def contact"



# ------------- Authenticate Users -------------------------------
    inject_into_file "app/controllers/application_controller.rb", "\n    # before_action :authenticate_user!
    before_action :configure_permitted_parameters, if: :devise_controller?

    rescue_from CanCan::AccessDenied do |exception|
        redirect_to root_path, :alert => exception.message
    end

protected

    def configure_permitted_parameters
        devise_parameter_sanitizer.for(:sign_up) { |u| u.permit({ roles: [] }, :email, :password, :password_confirmation, :name, :cpf, :cnpj, :client, :provider) }
        devise_parameter_sanitizer.for(:account_update) { |u| u.permit({ roles: [] }, :email, :password, :password_confirmation, :current_password, :name,:cpf, :cnpj, :client, :provider) }
    end\n", after: "protect_from_forgery with: :exception"

# ------------- Adds Navigation Bar to WebSite -------------------------------
    copy_file "_navigation.html.erb" , "app/views/layouts/_navigation.html.erb"
    copy_file "_navigation_links.html.erb" , "app/views/layouts/_navigation_links.html.erb"
    copy_file "application.html.erb" , "app/views/layouts/application.html.erb"

# ------------- Create Views -------------------------------
    copy_file "about.html.erb" , "app/views/static_pages/about.html.erb"
    copy_file "about.html.erb" , "app/views/static_pages/contact.html.erb"
    copy_file "about.html.erb" , "app/views/static_pages/help.html.erb"
    gsub_file("app/views/static_pages/help.html.erb", "<h1>About</h1>", "<h1>Help</h1>")
    gsub_file("app/views/static_pages/contact.html.erb", "<h1>About</h1>", "<h1>Contact</h1>")
    copy_file "home.html.erb" , "app/views/static_pages/home.html.erb"
    
# ------------- Add some Styling to WebSite -------------------------------
# 

    copy_file "docs.css" , "app/assets/stylesheets/docs.css"
    copy_file "custom.js" , "app/assets/javascripts/custom.js"

# ------------- Configure Friendly ID TO hide ID from URL------------------------------- 
    gsub_file("config/initializers/devise.rb","# config.scoped_views = false","config.scoped_views = true")
    inject_into_file "app/models/user.rb","\nextend FriendlyId
  friendly_id :name, use: :slugged
", after: "ActiveRecord::Base"

# ------------- Configure Mail address of Mandrill ------------------------------- 
    gsub_file("config/initializers/devise.rb","# config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'","config.mailer_sender = 'info@#{project_name}.com'")
    #inject_into_file "app/models/user.rb","\n    config.mailer_sender = 'info@#{project_name}.com'", after: "ActiveRecord::Base"

# ------------- Adds abilities to Users -------------------------------
    

inject_into_file "app/models/ability.rb","\n    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all
    else
      can :read, :all
    end
    ", after: "def initialize(user)"

# ------------ Configure Stylesheets --------------------------------   

    gsub_file("app/assets/stylesheets/application.css.scss", "*= require_tree .
 *= require bootstrap
 *= require chosen
 *= require_self", "*= require bootstrap
 *= require chosen
 *= require_tree .
 *= require_self")
    remove_file "app/assets/stylesheets/simple.css"
    copy_file "simple.css", "app/assets/stylesheets/simple.css"

    inject_into_file "app/assets/javascripts/application.js", "//= require bootstrap\n", before: "//= require_tree ."

# ------------ Config Database Pass and User to NULL --------------------------------     
# 
    gsub_file("config/database.yml", "username:", "# username:" )
    gsub_file("config/database.yml", "password:", "# password:" )


# ----------- Recreate app in all environments ---------------------------------     
#    
    rake("db:drop")
    rake("db:schema:cache:clear")
    rake("db:create")
    rake("db:migrate")
    rake("db:schema:cache:dump ")
    rake("assets:clean")
    rake("assets:precompile")
    rake("cache_digests:dependencies")
    rake("cache_digests:nested_dependencies")


    inside Rails.root do
        run "rake db:drop RAILS_ENV=production"
        run "rake db:schema:cache:clear RAILS_ENV=production"
        run "rake db:create RAILS_ENV=production"
        run "rake db:migrate RAILS_ENV=production"
        run "rake db:schema:cache:dump RAILS_ENV=production"
        run "rake assets:clean RAILS_ENV=production"
        run "rake assets:precompile RAILS_ENV=production"
        run "mkdir ./tmp/pids"
    end

  end
  
  private

  
  

end
