# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

- Ruby version 3.4

- System dependencies

- Configuration

- Database creation

- Database initialization

- How to run the test suite

- Services (job queues, cache servers, search engines, etc.)

- Deployment instructions

- ...

Hello There Dev,

Here's hwto start the backend application for ticker.

step 1 - glone this repository to your local device using git clone https://github.com/therealtomisin/ticketer-backend.git

step 2 - Make sure you have postgresql running in your local device

step 3 = proceed to install all gems using bundle install

step 4 = set up your environment variables by creating an env file similar to the .env.exampleyou see

step 5 = visit the database.yml file to see if you want to make changes to the database being used

step 6 = run rails db:prepare to create your database and migrate all the changes

step 7 = run rails generate solid_queue:start

step 8 = That's it,you're good to go!

run rails s to start your server and proceed to setup forntend application!
