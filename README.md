# Notification API

RESTful API for a basic CRUD notifications service

## Dependencies

- Ruby 2.3.4
- Bundler
- MySQL

## Installation

After cloning project

### Install gems

 ```shell
 $ bundle install
 ```

### Configure database

 Rename `database.sample.yml` to `database.yml`. Update file if necessary. Default values most likely will do fine on a dev box.

 ```shell
 $ mv config/database.sample.yml config/database.yml
 ```

### Create database

 ```shell
 $ bundle exec rake db:create
 ```

### Run migrations

```shell
 $ bundle exec rake db:migrate
 ```

### Start webserver

 ```shell
 $ rackup -p 3000
 ```

## Swagger Docs

Swagger documentation is hosted under root path, http://localhost:3000

## Docker

To run application on docker:

- Install [Docker](https://docs.docker.com/docker-for-mac/install/) and Docker-Compose
- Clone the project
- Run below commands in project root

```shell
$ docker-compose build
$ docker-compose up

# Open an other terminal and run
$ docker-compose run web bundle exec rake db:create db:migrate
```

## Console

To use console, run the following command:

```shell
$ bin/console
```

## Tests

Migrate db if necessary

```shell
$ RACK_ENV=test bundle exec rake db:migrate 
```

Run all rspecs

```shell
$ bundle exec rspec
```

## Routes

The below command lists all valid api routes

```shell
$ bundle exec rake routes
```
