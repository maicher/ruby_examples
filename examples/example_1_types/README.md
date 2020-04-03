In DDD there is a concept called "domain type" (ref needed).

They exist within bounded contexts.

Because we have no bounded context in Rails apps we build, our "domain types" are available in the whole app.

That's why it make sense to put them into `./lib/types.rb`.

The basic version would be build from primitives types, predefined in dry-types:

```
./lib/types.rb
require 'dry-types'

module Types
  include Dry::Types.module
end
```

All predefined types: https://dry-rb.org/gems/dry-types/1.2/built-in-types/

Use types by calling `#call`, eg:
```
  Types::Strict::String.call('abc')
  Types::Strict::String['abc']
```

Exercise: Understand the difference between:
```
Types::Strict::String vs Types::Coercible::String
Types::Strict::String vs Types::Strict::String.optional
Types::Nominal::Date (or Types::Date in older versions) vs Types::Params::Date
```

Try following:
```
Types::Strict::Array.of(Types::Strict::String.enum('a', 'b', 'b'))
Types::Strict::String.constrained(min_size: 3)
```

Domain type eg.
Say we building app enabled on 3 domains: pl, co.uk, com.
We introduce following type:

```
module Types
  Tld = Types::Coercible::String.enum('pl', 'co.uk', 'com')
end
```

We can reuse it:

In model:
```
class BlogPost < AR
  enum tld: Types::Tld.values
end
```

In validations:

```
class BlogPostCreateContract < ..
  params do
    required(:title).filled
    required(:tld).filled { Types::Tld.rule }
  end
end
```

To build value objects:

```
  module SendGrid
    class TemplateData < Dry::Struct
      attribute :user_name, Types::Strict::String
      attribute :tld, Types::Tld
    end
  end
```
