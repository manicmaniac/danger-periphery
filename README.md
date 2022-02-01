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

## Advanced Usage

You can modify warnings as you like by passing a block to `process_warnings`.
`process_warnings` takes a block that receives `[path, line, column, message]` as arguments and returns one of the following types.

- `Array` that exactly contains `[path, line, column, message]`
- `true`
- `false`
- `nil`

If an `Array` is returned, danger-periphery uses the values in an array instead of the raw result produced by Periphery.
`true` has the same meaning as `[path, line, column, message]`, the argument array as-is.

If it returns `false` or `nil`, the processing warning will be suppressed.

For example, if you want your team members to be careful with warnings, the following code may work.

```ruby
periphery.process_warnings do |path, line, column, message|
  [path, line, column, "Pay attention please! #{message}"]
end
```

Or if you want to suppress all `unused` warnings, to return `nil` or `false` in the block works.

```ruby
periphery.process_warnings do |path, line, column, message|
    !message.match(/unused/i)
end
```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bin/download_periphery` to install Periphery.
4. Run `bundle exec rake spec` to run the tests.
5. Use `bundle exec guard` to automatically have tests run as you make changes.
6. Make your changes.
