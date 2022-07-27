# danger-periphery

[![Test](https://github.com/manicmaniac/danger-periphery/actions/workflows/test.yml/badge.svg)](https://github.com/manicmaniac/danger-periphery/actions/workflows/test.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/1006dd155fc527b2b687/maintainability)](https://codeclimate.com/github/manicmaniac/danger-periphery/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/1006dd155fc527b2b687/test_coverage)](https://codeclimate.com/github/manicmaniac/danger-periphery/test_coverage)
[![Gem Version](https://badge.fury.io/rb/danger-periphery.svg)](https://badge.fury.io/rb/danger-periphery)

A Danger plugin to detect unused codes.

<img width="899" alt="image" src="https://user-images.githubusercontent.com/1672393/181256005-40842f99-d504-4be8-a0e5-5df144f939d7.png">

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

### Postprocess warnings by passing block to `#scan`

You can modify warnings as you like by passing a block to `scan`.
`scan` takes a block that receives `ScanResult` instance as arguments.
Each `ScanResult` instance corresponds with each entry of Danger warnings.
If that block returns falsy value, danger-periphery suppresses the corresponding warning.

For example, if you want your team members to be careful with warnings, the following code may work.

```ruby
periphery.scan do |violation|
  violation.message = "Pay attention please! #{violation.message}"
end
```

For another example, if you want to suppress warnings complaining about unused parameter of many of `didChangeValue(_ sender: Any)` methods, you can suppress this kind of warnings in the following way.

```ruby
periphery.scan do |violation|
  ! violation.message.match(/Parameter 'sender' is unused/)
end
```

### Postprocess warnings by calling `#process_warnings`

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
3. Run `bin/download-periphery` to install Periphery.
4. Run `bundle exec rake spec` to run the tests.
5. Use `bundle exec guard` to automatically have tests run as you make changes.
6. Make your changes.
