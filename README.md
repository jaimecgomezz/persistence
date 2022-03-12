# persistence
Abstract the persistence layer away from the code that really matters.

## Motivation

When I first got introduced to ruby, it wasn't really to the language itself but rather, as Richard Feldman [calls it](https://youtu.be/QyJZzq0v7Z4?t=176), to its killer app, [Rails](https://rubyonrails.org/). I quickly fall in love with it, as it was incredibly easy and quick to make anything happen, even more so, I absolutely loved [Active Record](https://guides.rubyonrails.org/active_record_basics.html); it felt so natural to query the database that most of the time I was chatting with it.

Unfortunately, as you progress both with your application and with your software engineer career, you start to realize that that incredible level of abstraction comes with a cost; speed and code-base obscurity. I remember once pulling the entire project simply to find a specific method that I wanted to know more about, only to get lost in an ocean of meta programming, so vast and confusing that the easiest path for me was to reinvent the wheel.

`persistence` offers an Active-Record-like, but not really, experience, following design patterns that guarantee the testability and extendability of the project.

Please see the [limitations](#limitations) of the project.

## Concepts

We'll dive into `persistence`'s foundations by exploring one of the simplest and most intuitive queries available, finding a User by its ID. I'd suggest the reader to follow the [General diagram](diagrams/find-by-id-general.png) along with the reading.

### Repository

The Repository is an object that mediates between the [Client](#client) and the persistence layer. It confines persistence logic to a low level, and offers a standardized API to query the [Storage](#storage).

For simplicity sake, we'll assume that you have already defined the `user_repository` and that you expect the results of said repository to be [hashes](https://ruby-doc.org/core-3.1.1/Hash.html). What you would do is simply:

```ruby
> user_repository.find_by_id(1)
=> { id: 1, email: 'an@email.com', ... }
```

Up until this point you don't know what mechanisms, nor how they might be implemented, run under the hood for you to easily obtain the `user` you were looking for, and you might never need to know, which es perfectly fine. The only important thing for you, as the Client, is to obtain what you are looking for.

This simple concept allows the developer to mock the **entire** Storage, and build on top of the Repositories. This is what we define as **storage independent**, allowing the developers to postpone storage decisions.

This concept is borrowed from the [Hanami](https://github.com/hanami/hanami) project.

### Engine

The Engine is merely a proxy between the Repository and the many Operations available. Its purpose is to expose a simple and stable API to access said Operations.

Following the example above, if we ever decide to uncover the secrets being hidden by the `user_repository`, we'll be soon to find that its implementation is really simple:

```ruby
def find_by_id(id)
    identity_transformer.one(engine.select.where({ id: id }))
end
```

Although there are a couple of things to unpack here, we will only focus in the `engine.selection.where({ id: id })` section. See, if we were to `delete` a record with ID `1`, what we would expect to see it's *almost* the same:

```ruby
def delete_by_id(id)
    identity_transformer.one(engine.delete.where({ id: id }))
end
```

This should communicate the notion of the Engine being simply a gate keeper for all the operations available, allowing us to use, share and inject the Engine however we want, with the guarantee that the Operations will come along.

### Operation

An Operation is nothing more than the sum of its Capabilities. This can be understood quite literally and metaphorically.

I know the definition above isn't enough to fully grasp what an Operation might be, that's why we decide to peak into the [Select](lib/persistence/store/operations/select.rb) operation we invoked earlier with `engine.select`. What we would found is something like this:

```ruby
module Operations
    class Select
        include Capabilities::Filter
        # ... many other includes
    end
end
```

It is just a class definition with a bunch of `include`s... so that's what the `nothing more than the sum of its Capabilities` phrase meant? I see

#### Capability

By now you might get the grasp of what a Capability does, but here is it: It defines a **single specific** behavior that an Operation will acquire when including it in its definition.

With that in mind, we can expect the [Filter](lib/persistence/store/operations/capabilities/filter.rb) Capability to allow filters definition for those Operations that `include` it. If we were to peak into its content, what we would find is something like this:

```ruby
module Capabilities
    module Filter
        def where(filters = nil)
            # ... implementation details
        end

        def where_not(filter = nil)
            # ... implementation details
        end
    end
end
```

As you might expect, the [Grouper](lib/persistence/store/operations/capabilities/grouper.rb) Capability makes grouping definitions available for our Operation, while the [Paginator](lib/persistence/store/operations/capabilities/paginator.rb) makes the Operation results capable of being paginated. Do you see where are we going with this? We can define any number of Operations with any number of Capabilities and expect them to work; they act merely as a container for specific behavior.

This decision was made consciously, following the [Single Responsibility Principle](https://en.wikipedia.org/wiki/Single-responsibility_principle), making them atomic and testable.

### Driver

What we have described until now are the `Abstract` layer components, the ones that should be able to work exactly the same, no matter what Storage we're dealing with. What is about to come is the `Specialized` layer, which is composed mainly of the Driver and the Storage itself.

The Driver is probably the most important component of the project, in the sense that without it, no matter how simple or complex abstractions we build on top, we wouldn't be able to do anything useful with them.  Considering this, we can say that:

The Driver is responsible for transforming the abstract notion of an Operation into a concrete [Directive](#directive) that can be understood and then executed by our Storage.

Following the previous example, say our Storage is [Postgres](https://www.postgresql.org/). In that case, we'd use the existing [Postgres Driver](lib/persistence/store/drivers/sequel/postgres.rb) that knows how to transform our `Select` Operation into the a concrete `SQL` statement.

```ruby
> postgres_driver.build(select_operation)
=> ["SELECT * FROM users WHERE id = :where_a_id", { where_a_id: 1 }]
```

The above example uses the `#build` method that every Driver is expected to implement. Its purpose is to allow the user to debug the Directive that the driver would run in a common execution. But, what would normally happen is something like this:

```ruby
> postgres_driver.run(select_operation)
=> [{ id: 1, email: 'an@email.com', ... }] # Storage results
```

All this is what I consider the main value proposition of the project; as long as a Driver for our Storage exists, we should be able to work with it, while maintaining a homogeneous development experience.

### Storage

The concrete persistence mechanism of our preference, whatever that might be,  [Postgres](https://www.postgresql.org/), [Elasticsearch](https://www.elastic.co/elasticsearch/), [Redis](https://redis.io/), etc.

#### Directive

The instructions that our Storage understands, for example, Postgres' directives are SQL statements.

### Transformer

Remember the snippet of code we inspect in the [Engine](#engine) section?

```ruby
def find_by_id(id)
    identity_transformer.one(engine.select.where({ id: id }))
end
```

We decided to ignore the `transformer.one` part since it wasn't important up until that moment, but now is time to take a look at it:

The Transformer is responsible for consuming the Operation results and returning them in the format, recipient or whatever form the Client expects them to be. They expose only 2 methods, `#one` and `#many`, each intended to be used when a single result or a list of multiple results are expected, respectively.

For example, [Active Record](https://guides.rubyonrails.org/active_record_basics.html) automatically transforms the Storage results into [Models](https://guides.rubyonrails.org/active_record_basics.html#creating-active-record-models), so instead of receiving plain hashes when querying the Storage, you get class instances.

Following our example, we said that we expected our results to be plain hashes, and since our Storage already returns the results in exact form, we technically don't need to pass them through the Transformer, but we do it to maintain a homogeneous experience in all of our repositories. This is why the [Identity Transformer](lib/persistence/transformers/identity_transformer.rb) , which is the the Transformer used by default in every Repository, is a concept so simple yet so powerful, inspired by the  [#identity](https://ramdajs.com/docs/#identity) method from [Ramda.js](https://ramdajs.com/) and the [Null Object Pattern](https://en.wikipedia.org/wiki/Null_object_pattern). 

### Entity

Finally, an *entity* is an object defined not by its attributes, but its [identity](https://en.wikipedia.org/wiki/Identity_(object-oriented_programming)). It deals with one and only one responsibility that is pertinent to the domain of the application, without caring about details such as persistence or validations.

Returning to our example, if we were to expect our results in an Active-Record-like fashion, what we'd have could be:

```ruby
class User
    attr_accessor :id, :email
end

setter_transformer = SetterTransformer.new(User)

> setter_transformer.one(engine.select.where({ id: 1 }))
=> #<User @id=1 @email='an@email.com' ... >
```

The [Setter Transformer](lib/persistence/transformers/identity_transformer.rb) is one of the Transformers already available. It consume a class at its initialization, and then, when either the `#one` or the `#many` methods are invoked, it transforms the results into an instance or a list of instances of the class provided, with all the attributes already in place.

This is concept inspired by the [Domain Driven Design](https://en.wikipedia.org/wiki/Domain-driven_design#Building_blocks).

### Client

You, while you're testing, and your application the rest of the time.

## Limitations

1. The project is not production ready. This is still a v0.1.0.
2. There are so many and so distinct DBs out there that we will **never** expect to be the finest solution for each one. The main purpose of the project is to allow developers with common requirements to use and extend the project. If you need really complex interactions with your niche DB, chances are that it'd will never be the right solution for you.
