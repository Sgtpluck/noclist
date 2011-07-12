# Noclist

Retrieve the NOC list

## Setup

I am using a MacBook Pro (Retina, 15-inch, Mid 2015) running MacOS Catalina 10.15.5.

- clone the repo from GitHub
- cd into the root directory
- if you don't have bundler, run `gem install bundler`
- run `bundle install`
- Ensure you have the adhoc development server running
  - Check if you have Docker running on your desktop. You can check by running `docker` in your terminal
    - If not, download Docker. [Docker Desktop](https://www.docker.com/products/docker-desktop) is an easy way to do so!
    - Start Docker Desktop
  - open a new terminal window and run
    `docker run --rm -p 8888:8888 adhocteam/noclist`
    - note: if you get an error like `Error response from daemon: dial unix docker.raw.sock: connect: no such file or directory.` you may have to either restart Docker, or run `docker start` (if you're not using Docker Desktop)
  - You should see Listening on http://0.0.0.0:8888.

## Running tests

- run `bundle exec rspec` from the root directory

## Running the code

- run `bundle exec bin/noclist` from the root directory

## to debug

- include pry in the file `require pry`
- include the configuration

```ruby
Pry.config.input = STDIN
Pry.config.output = STDOUT
```

- add `binding.pry` where you'd like to set a breakpoint
