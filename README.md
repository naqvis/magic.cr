# magic.cr

Crystal bindings to `libmagic`.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     magic:
       github: naqvis/magic.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "magic"

# File Name
puts Magic.detect("README.md")

# File object
File.open("README.md") do |file|
  puts Magic.detect(file)
end

# Contents
puts Magic.detect(File.read("README.md").to_slice)
```

## Contributing

1. Fork it (<https://github.com/naqvis/magic.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Ali Naqvi](https://github.com/naqvis) - creator and maintainer
