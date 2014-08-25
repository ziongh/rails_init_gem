# RailsInitGem: A Gem to Integrate them All
[![Gem Version](https://badge.fury.io/rb/rails_init_gem.png)](http://badge.fury.io/rb/rails_init_gem)

The idea of this Gem id to Create a functioning Rails Project integrating lots of different Gems in such a way, that the resulting Project can be used in any Production Project. This version is the first one, and probably has some Bugs. I hope people will Help me to Keep this Updated.

This gem create a initial application with:

	simple_form;
	devise (User);
	email confirmation;
	can-can (permitions);
	rolify (more permissions);
	bootstrap (beatiful layouts);
	postgres (fast database);
	Html compression (faster navigation);
	Css and Js compression (faster navigation);
	Redis Ready (can use cache solution Redis);
	mandrill mailer (mailing solution);
	unicorn (fast server);
	Will_paginate (pagination) (TODO);
	Elastic_Search (Full-text search) (TODO);
	Resque and whenever (background jobs) (TODO);
	PayPal (payment solution) (TODO)
	

## Installation

Add this line to your application's Gemfile:

    gem 'rails_init_gem'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails_init_gem

## Usage

	$ rails g NewProject

Another Option is to execute the railsNew.sh shell script, which will do the steps mention above

	$ ./railsNew.sh NAME_OF_THE_PROJECT

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rails_init_gem/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request