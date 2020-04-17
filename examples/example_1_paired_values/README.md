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
Types::Strict::Array.of(Types::Strict::String.enum('a', 'b', 'c'))
Types::Strict::String.constrained(min_size: 3)
```

Domain type eg.

Say we're building app enabled on 3 domains: pl, co.uk, com.
We introduce following type:

```
module Types
  Tld = Types::Coercible::String.enum('pl', 'co.uk', 'com')
end
```

We can it:

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

If type is a pair of values, eg like  money:

```
class Price < Dry::Struct
  attribute :cents, Types::Strict::Integer
  attribute :currency, Types::Strict::String.enum('PLN', 'USD')

  def to_s
    [(cents.to_f / 100).round(2), currency].join
  end
end
```

Map it to db by AR:

```
# migrations
def up
  add_column :meals, :price_cents, :integer, null: false
  add_column :meals, :currency, :string, null: false
end

# models/meal.rb
class Meal
  def price
    Price.new(
      cents: price_cents,
      currency: price_currency
    )
  end
  
  def price=(price_dry_struct)
    self.price_cents = price_dry_struct.cents
    self.price_currency = price_dry_struct.currency
    price_dry_struct
  end
end
```

Build up with handy factory methods.

```
class Price < Dry::Struct
  def self.usd(cents)
    new(cents: cents, currency: 'USD')
  end

  def self.pln(cents)
    new(cents: cents, currency: 'USD')
  end

  ....
end

meal = Meal.new
meal.price = Price.usd(123)
meal.save!
meal.price.to_s
=> 1.23USD
```

Different formatters:
```
class Price < Dry::Struct
  FORMATTERS = {
    normal: ->(cents, currency) { [cents, currency].join }
    inverted: ->(cents, currency) { [currency, cents].join }
  }.freeze

  def self.usd(cents)
    new(cents: cents, currency: 'USD', formatter: :inverted)
  end

  def self.pln(cents)
    new(cents: cents, currency: 'USD' formatter: :normal)
  end

  attribute :cents, Types::Strict::Integer
  attribute :currency, Types::Strict::String.enum('PLN', 'USD')
  attribute :formatter, Types::Strict::Symbol.enum(FORMATTERS.keys)

  def to_s
    FORMATTERS[formatter].call(
      (cents.to_f / 100).round(2),
      currency
    )
  end
end

Price.usd(123).to_s
=> USD1.23

Price.pln(123).to_s
=> 1.23PLN
```

Why bother?
I know there's the money gem, with additional features.
The thing is that similar concepts often occurre in projects. 

I used money as easy relatable example.

Eg. from Nutrifix:

We had hard time modeling nutrients. Different nutrients were in different units in db,
and the knowledge which nutrient is in which unit was hardcoded. Currently all are in grams.
But if a nutrient had to be say milli-liters - we hit the dead end.

It could be modeled similarly to money.

Eg:

```
class Nutrient < Dry::Struct
  attribute :name, Types::Strict::String
  attribute :value, Types::Strict::Integer
  attribute :unit, Types::Strict::String.enum('ug', 'mg', 'g', 'ml', 'l')

  def value_with_unit
    [value, unit].join
  end
end
```

Then it can be used with AR:

```
class Meal
  def proteins
    Nutrient.new(
      name: 'Proteins',
      value: proteins_value, # reader, from db
      unit: proteins_unit    # reader, from db
    )
  end
  
  def fiber
    Nutrient.new(
      name: 'Fiber',
      value: fiber_value,
      unit: fiber_unit
    )
  end
end
```

TODO: example how to use it in dry-validations.
TODO: convenrions example.

Dynamic typing.
Because Ruby is knows as dynamic typed lang, there's a level of confusion/dyssonance about dry-types and dry-struct.

But the dissonance diapear after understanding that dry-struct and dry-types doesn't interfeere with the duck-typing, dynamic-typing
concepts in Ruby. Because these concepts don't apply to datastructures. 

In short. On the highest level of detail (the highest resolution of data) there are types. Ruby provides methods
fore enforcing/coercing them (eg. #Integer).

The impression you get that thinking about them can be omitted is because AR handles them implicitly, inferring from DB structure. 

Common write request we build:

`params from api or form -> controller -> service (or other abstraction) -> AR model -> database (postgres)`

AR model performs needed coercions, time is changed to date, money gem's transforming units to cents, etc. Types are handled before writing to db - implicitly.

Learn dry-types and dry-struct to be able to handle types freely, precisely, expicitly. Build own, custom primitive types
and data containers (value objects, entities) that keep their consistency. 

Other eg. height - cm/inch, weight - kg/lbs.
 