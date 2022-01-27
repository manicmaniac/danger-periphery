# danger-periphery

[![Test](https://github.com/manicmaniac/danger-periphery/actions/workflows/test.yml/badge.svg)](https://github.com/manicmaniac/danger-periphery/actions/workflows/test.yml)

A Danger plugin to detect unused codes.

## Installation

You need to install [Periphery](https://github.com/peripheryapp/periphery) beforehand.

Write the following code in your Gemfile.

```ruby
gem "danger-periphery"
```

## Usage

If you already have `.periphery.yml`, the easiest way to use is just add this to your Dangerfile.

```ruby
periphery.scan
```

You can specify the path to executable in this way.

```ruby
periphery.binary_path = "bin/periphery"
```

You can pass command line options to `periphery.scan` like the following.
See `periphery scan -h` for available options.

```ruby
periphery.scan(
  project: "Foo.xcodeproj",
  schemes: ["foo", "bar"],
  targets: "foo",
  clean_build: true
)
```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bin/download_periphery` to install Periphery.
4. Run `bundle exec rake spec` to run the tests.
5. Use `bundle exec guard` to automatically have tests run as you make changes.
6. Make your changes.
