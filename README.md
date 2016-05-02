![](http://i.imgur.com/jDIg5Xi.png)
# Active Model Flags Gem
![Travis build for User Timezone Gem](https://travis-ci.org/jayelkaake/activemodel_flags.svg?branch=master)
[![Gem Version](https://badge.fury.io/rb/activemodel_flags.svg)](https://badge.fury.io/rb/activemodel_flags)
The Active Model Flags Gem lets you attach the `has_flags` trait to your User, Account, or any other rails active models.

## Why would you need a flags attribute and this gem?
For some applications you don't want ot add a million different attributes in your database for flags that are potentially one-time events. For example, if you wanted to track whether a user has been notified of something, or has been sent an email. These arbitrary flag columns start to clutter your DB.

The Active Model Flags gem solves this issue by allowing you to arbitrarily set and get flags from a serialized column.

**Table of Contents**
* [Installation](#installation)
* [Usage](#usage)
    * [Getters](#getters) 
    * [Setters](#setters)
    * [Querying](#querying)
        * [Get models that have or don't have the flag set](#get-models-that-have-or-dont-have-the-flag-set) 
        * [Get all available flags](#get-all-available-flags) 
        * [Set the flags for a group of users](#set-the-flags-for-a-group-of-users) 
        * [Reset a particular flag for some users](#reset-a-particular-flag-for-some-users) 
        * [Nuke (reset) all flags](#nuke-reset-all-flags) 
* [Customization](#customization)
* [Other Things](#Other_Things)

# Installation
#### 1. Install the gem
Add this line to your application's Gemfile:
```ruby
gem 'activemodel_flags'
```
And then execute:
    $ bundle
Or install it yourself as:
    $ gem install activemodel_flags

#### 2. Add 'has_flags' to your model
Choose the model you want to have flags and add the `has_flags` function to it. For example, with a User model this may look like this:
```ruby
class User < ActiveRecord::Base
  # ...
  has_flags
  # ...
end
```

#### 3. Run the migration to add the DB column
Then, you'll need to install the column in your database. This gem comes with this generator for you that you can use like this:
```bash
rails g activemodel_flags:column User
rake db:migrate
```
Replace `User` with your own model class.




# Usage

## Setters
Once a model has_flags then you can now set a flag like this:
```ruby
user = User.create

user.has! :been_sent_email_about_usage

user.has? :been_sent_email_about_usage
# false
```
or you can do the opposite:
```ruby
user = User.create

user.hasnt! :been_sent_email_about_usage

user.has? :been_sent_email_about_usage
# true
```

To set the value without saving to the DB use `user.has :been_sent_email_about_usage`.

## Getters
Consider this example to see how the getters work:
```ruby
user = User.create

user.has! :been_sent_email_about_usage

user.has? :been_sent_email_about_usage
# true

user.hasnt? :been_sent_email_about_usage
# false

user.has? :been_eating_a_big_chocolate_cake
# false
```

## Querying
Generally this gem is not made for mass querying, so if you plan on doing joins based on the flag attribute then this gem is probably to for you and you should use a boolean column.

### Get models that have or don't have the flag set
That being said, here's how you can use the
```ruby
User.that_havent?(:been_sent_email_about_usage) do |user|
  # * send that user the email about usage here. *
  user.has! :been_sent_email_about_usage
end
# Returns query list of all users that have been sent a message
```

### Get all available flags
If you want to now what flags are being used for **debugging purposes** then you can use
```ruby
u = User.flags_used
# returns something like ["been_sent_email_about_usage", "been_eating_a_big_chocolate_cake"]
```

### Set the flags for a group of users
```ruby
User.where("age > ?", 40).all_have! :seen_james_bond_movies
# Sets the seen_james_bond_movies flag to true for all matched users.
```
And to do the opposite (set the flag to false for all matched users):
```ruby
User.that_have?(:used_a_cd).where("age < ", 20).all_have_not! :felt_the_anger_of_skipping_cds
# Sets the felt_the_anger_of_skipping_cds flag to false for all matched users
```

### Reset a particular flag for some users
```ruby
User.where(took_the_red_pill: true).reset_flags! :been_in_the_matrix
# Now all users that were matched will return false for has?(:been_in_the_matrix)
```

### Nuke (reset) all flags
```ruby
User.reset_all_flags!
```

# Customization
Models that have the has_flags trait will call the protected method `on_flag_change(old_val, new_val)` any time the value of their flag changes, but only if it is done individually.

Feel free to fork and contribute so we can make this better!

# Other Things
### Roadmap
* Build in method_missing functionality so you can do things like `model.has_eaten_a_pie!` and `model.has_eaten_a_pie?`
* Make the flags column customizable so you can add multiple flag columns
### Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/jayelkaake/user_timezone.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

### License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
