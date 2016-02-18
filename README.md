![trademate logo](https://status.trademate.de/images/trademate.png)

# trademate

Ruby wrapper for the [trademate](https://trademate.de/) e-commerce API

## Work in progress

This gem is under heavy development. Please do not use yet.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'trademate'
```

And then execute:

```
$ bundle
```

The trademate gem is tested on Ruby 2.0.0, 2.1.x and 2.2.x. It requires ruby version 2.0 and up.

## Usage

Initialize a client instance by providing your API keys:

```ruby
require 'trademate'

trademate = Trademate::API.new('consumer_key', 'consumer_secret', 'access_token', 'access_token_secret')
```
