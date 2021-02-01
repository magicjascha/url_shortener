# UrlShortener

Small web app which provides short redirecting links if you enter an url. 

## Setup for development

If you have docker installed and are using a very different system you can use docker (see below). However in docker the test environment is not configured yet.

### Without Docker

The commands might diverge for other systems than Ubuntu LTS 20.04

Install rubygems, the newest stable ruby version 3.0.0 and bundler  

Clone the project, change into the root folder 'url_shortener' and install the necessary gems:

```bundle install```

Download and install the mongodb database:
https://docs.mongodb.com/manual/installation/

Start the database.
```sudo service mongod start```

By setting the environment_variable US_TOKEN_LENGTH you can decide on the length of the redirecting links.
E.g. with $US_TOKEN_LENGTH = 4 resulting short links will look like
```[domain-name]/2j1n```
The tokens are build from an alphanumerical alphabet (the 36 characters 'a'-'z' and '0'-'9'). The default length is 8 characters. The shorter the tokens are, the higher is the probability for 
1. collisions, i.e. failing user requests to save urls
2. users guessing other users short-urls

Start the app by going to the root directory and running:

```rackup```

or from anywhere:
```rackup [path_to_apps_root_folder]/config.ru```

In development the app will be running on the default port 9292. So the app can be accessed via: http://localhost:9292

New short-urls can be created by navigating to root. The new short-url ist returned together with the other shortcuts that where created within the same session.

### With Docker

Clone the project, change into the root folder 'url_shortener'

in case your user is not allowed to access docker use sudo
```docker-compose build```
```docker-compose up```

You can find the app in the browser then directly under localhost/ (without port).

If it doesn't work check if docker is running with
```systemctl status docker```

Mind that you can change the token length with the environment variable US_TOKEN_LENGTH
e.g. by inserting into the Dockerfile before the last line
```ENV US_TOKEN_LENGTH 6```

## Setup for production

* The docker configuration still runs the app in development mode. There to be an additional database production configurations in config/mongoid.yml with an authentification.
* SSl should be enforced

## Test

in the terminal you can run all tests at once with

```rake test```

or the single files in directory /test with

```ruby test/integration_test.rb```

or the single tests with option -n:
```ruby test/controller_test.rb -n test_post_valid_url_saves_to_database```


## Explanations for technical choices in this app

### Framework

Sinatra was chosen over more comprehensive frameworks like rails as my app has just a single purpose. While Rails is great for offering solutions for a variety of tasks, for simple apps it is slower and brings too much dependencies, i.e. maintainance-work. As Sinatra apps can be mounted inside rails, there are also no problems with building on the accomplished work, should it later on be decided, that a bigger rails app, with more functionality is needed.

### Database

Since by definition url-shortening does not allow for 1-to-1-transformations by algorithms there is the need for a database that remembers pairs of long and shortened urls.

As scalability was required I would usually think of a Postgres-database, as it is for free, scalable and also widely supported by database hosting services. As my data has clear structures, SQL-databases are more performant. They also provide clearer guidelines for developers to build easily maintainable and searchable datastructures than nosql databases for the future. However, as gapfish is using mongoDB I thought this was a good moment to have a first look into it. 

The advantage of mongodb is I will be able to add other datastructures more easily. Also mongodb is especially fit and easy to configure for distributed systems. Should I want to scale up I can easily setup a cluster with a replication system.

With mongoid I chose the ODM which seemed most straight forward to me.

### Docker
As there is not too much to configure, docker is not a must have. However I wanted to try out docker, as you are only one of many companies that use it by now.

### Short URl Construction

To exploit the adress-space for a given character length more completely I could have used an incremental index or an obfuscation of this index. For security reasons, as I didn't want the users be able to guess the other users urls, I decided against obfuscated incremental urls. 

Instead I just use a random mix of alphanumerical characters of given length. There is also ready solutions for this (e.g. https://github.com/thetron/mongoid_token ) but decided because it's small functionality and if I can easily avoid more dependencies I do it. With random alphanumeric characters I focused on shortness. However for an url-shortener that focuses more on human memorizability there would have been better options, e.g. https://github.com/jmettraux/munemo

To exclude for collisions of the random strings, it's made sure that the database takes only unique tokens. If this fails cause a token is already taken, it is retried 5 times, otherwise an error is thrown. At this point this should lead the admin to enhance the address-space by setting a higher value for the environment variable US_TOKEN_LENGTH, so an error is thrown.

### Tests

With minitest and racktest I used tools, that where easy to set up for me. For the integration tests I added Capybara so I could also mimic visual testing.

### Endpoints

Although there is almost not enough endpoints to see it, I fulfilled the RESTful pattern based on the resource "shortcut". The redirecting short-url-endpoints where not included in this pattern, but built as short as possible directly at root, as also suggested in the definition of the project.

### Code organization

I constructed the files according to the MVC-architecture. If there was more than one resource, it would also make sense to have separate controller files for each resource, but with four endpoints the main app file url_shortener.rb is still easy to read.

As much logic as possible was transferred into the model. Handing over also the session to the model might be unusual. With more session operations, I would probably put it in a module and include it, when I need it.

### Error Handling

For server errors there will be shown a custom error page to the user. One anticipated error, cause by scaling up massively or the admin is that the available address-space becomes too small. It got it's own custom error-class, so it can be recognized easily.

For "errors" caused by the user input, which will be more common, there is a redirect to or render of the new-view with a (flash)message indicating the failure, so that the user can generate another short-url. However there is an additional INFO-logging for requested non-existant short_urls, as this is something you might want to know about if it becomes unusual often.

### Frontend

The frontend is not very beautiful. I assumed there was not supposed to be any focus on it.