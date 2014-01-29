# Que-Mailer

Asynchronously send mail using ActionMailer and [Que](https://github.com/chanks/que).

So far, this has been tested only in Rails 4.

Que is an alternative DelayedJob or QueueClassic and is a queue for 
Ruby. It uses PostgreSQL's [advisory locks]
(http://www.postgresql.org/docs/current/static/explicit-locking.html#ADVISORY-LOCKS) 
to manage jobs. See the [que repo](https://github.com/chanks/que) for more details.

### Why Que-Mailer?

* Que-Mailer uses Postgres rather than Redis, RabbitMQ or other message queue.
  If you already have Postgres on a project, now you have 1 fewer dependency!
* Que-Mailer can create background workers within your existing process. This means,
  for instance, that your background workers and web server can share a Heroku dyno.
  It also means that you don't have to remember to launch separate workers.
* All of the benefits of using advisory locks and Postgres (like safety, 
  security, and atomic backups.)
  
### Warning

Que and Que-Mailer are fairly new compared to other queue
solutions. We're still finding bugs and have only tested
in a limited set of configurations.

If you have problems, please [post an issue](https://github.com/prehnRA/que-mailer/issues).

## Installation

Right now it is best to use the github master version.

Add this line to your application's Gemfile:

    gem 'que_mailer', :git => 'git://github.com/prehnRA/que-mailer.git', :branch => 'master'
    
And then execute:

    $ bundle
    
Additionally, you need to follow the steps for installing
and using Que. Remember to:

    $ rails generate que:install
    $ rake db:migrate
    
Which will get your database ready to store jobs.

## Use

You use Que-Mailer by including it in your mailers, like this:

    class ExampleMailer < ActionMailer::Base
      include Que::Mailer
      default from: 'from@example.com'
      
      def example_message(*args)
        @args = *args
        mail(to: "to@example.com", subject: "Hello World")
      end
    end

Then, 

    ExampleMailer.example_message.deliver 
    
will send mail using the background workers. 

    ExampleMailer.example_message.deliver!

will bypass Que and send the mail directly.

## Scheduling Mail

Additionally, you can schedule mail to be sent at a later
time.

    ExampleMailer.deliver_in(2.days)
    
will send an email two days from now.

    ExampleMailer.deliver_at(time)

will deliver the email at `time`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

You can also help by testing this in your application and 
reporting any issues you encounter.

## License

MIT