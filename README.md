# mongo-sinatra-admin

Web-based MongoDB admin interface written with Ruby and Sinatra

> **WARNING**: This is a development version: Currently under heavy development.

### Screenshots

<img src="http://i.imgur.com/WPBBoPl.png" title="Index Page" />

Click here for more screenshots:
[http://imgur.com/a/OTZHe](http://imgur.com/a/TGAZS)


## Usage

### To install

```
git clone git@github.com:mamantoha/mongo-sinatra-admin.git
cd mongo-sinatra-admin/
bundle install
```

### To configure

Copy or rename `config.json.example` into a new file. For development environment is `config_development.json`

Fill in your MongoDB connection details, and any other options you want to change.

### To run

```
rackup
```

### To use

Visit `http://localhost:9292` or whatever URL/port you enterd into you config.
