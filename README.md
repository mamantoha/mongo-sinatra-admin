# mongo-sinatra-admin

[![Ruby](https://github.com/mamantoha/mongo-sinatra-admin/actions/workflows/ruby.yml/badge.svg)](https://github.com/mamantoha/mongo-sinatra-admin/actions/workflows/ruby.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/87358a550b5db859316f/maintainability)](https://codeclimate.com/github/mamantoha/mongo-sinatra-admin/maintainability)

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

Fill in your MongoDB connection details, and any other options you want to change in `.env.*` file.

Create pseudo localization locale and generate `locales/en-ZZ.yml`:

```
bundle exec rake i18n:export_pseudo_i18n
```

### To run

```
rackup
```

### To use

Visit `http://localhost:9292` or whatever URL/port you entered into you config.

### Run specs:

```
bundle exec rake specs
```
