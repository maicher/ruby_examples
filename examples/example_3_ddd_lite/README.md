# DDD lite

Architectural pattern.
Split AR model responsibilities into smaller building blocks: entities, value object, repositories, factories and operations/services/transactions.

Useful when need to model a concept that is not 1:1 mapped to database.

It happens often.

A common approach in Rails world would be to user AR models normally and map on a level of presenters.

Eg there is a model

```
class Day < AR
end
```

We need to present a week to the user. 

We build presenter:

```
class WeekPresenter
  embeds 7 days
end
```

It's enough for presenting. But if if needed to be used in logic that is outside the presenters 
(eg in services, to perform some calculations, update smth, etc) - it's not a presenter anymore.

So it's a AR model. But it can't be modeled by AR. It's not a classic has many relation.

So we could build a model without AR, but the model would grow fast, because querying and persistence couldn't use
the build in AR methods/macros.

If this kind of confusion happens to me - it's a sign to go with DDD lite.

It provides a structured way of dealing with this confusion. Providing space between db and domain logic. 

Step 1. Define entity or value object - when to choose which one?

### If entity

- define repository _for_ this entity for reading and building
- define factory for this entity (optionally) for building
- define operations/services/transactions for writing

### If value object

- define factory for this entity for building


-----

- entities and value objects are data containers - can't query db
- AR models are degraded to to role of db adapters (no AR validations) 
- factories and repositories can query db using AR models or other factories and repositories
- operations/services/transactions writes to db using AR models
- validations are made before or as a first step of operations/services/transactions 

See examples.
