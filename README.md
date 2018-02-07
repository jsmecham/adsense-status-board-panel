# AdSense Status Board Panel

This Sinatra app can be used to pull in your earnings from Google AdSense
and display them on your [Status Board](http://panic.com/statusboard).

## Configuration

To configure your own instance of this panel, you should be familiar with
running Sinatra or Ruby on Rails instances. Of course, if you are not familiar
with setting up and running a Sinatra web application, the easiest route is to
use [Heroku](http://heroku.com). Please reference [this tutorial](https://devcenter.heroku.com/articles/git)
for more information about deploying to Heroku.

### Defining Your Credentials

You will need to provide your Google Client ID and Secret, which you can
obtain from the Google API Console at https://code.google.com/apis/console/.

Once you have your id and secret, you should update the `app.rb` file to
include them, like so:

    set :consumer_key, "<your client id>"
    set :consumer_secret, "<your client secret>"

## Author

Written by Justin Mecham ([email](mailto:justin@mecham.me),
[twitter](http://twitter.com/jsmecham)).

## License

This project is licensed under the terms of the MIT License.
