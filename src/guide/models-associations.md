---
title: Associations
type: guide
order: 24
---

With our ORM you can associate models with other models across all datastores. This means that your users can live in PostgreSQL and their photos can live in MongoDB and you can interact with the data as if they lived together on the same database. You can also have associations that live on separate connections or in different databases within the same adapter.

The following guides will walk you through the various ways that your data can be associated and how to setup and query associated data.

- <a href="#one-to-one">One-to-one</a>
- <a href="#one-to-many">One-to-many</a>
- <a href="#many-to-many">Many-to-many</a>
- <a href="#dominance">Dominance</a>

<div id="one-to-one"></div>
## One-to-One Associations

A one-to-one association states that a model may only be associated with one other model. In order for the model to know which other model it is associated with a foreign key must be included in the record.

The ORM uses the concept of a `model` attribute to indicate that a record should store a reference to another model. Whenever this attribute is found a `foreignKey` will be built up in the underlying schema to handle the association.

```js
// user.js - A user may only have a single pet
{
  attributes: {
    firstName: 'string',
    lastName: 'string',

    // Add a reference to Pet
    pet: {
      model: 'pet'
    }
  }
}

// pet.js - A Pet may have multiple users
{
  attributes: {
    breed: 'string',
    type: 'string',
    name: 'string'
  }
}
```

In the above example we are associating a `Pet` with a `User`. The `User` may only have one `Pet` in this case but a `Pet` is not limited to a single `User`. Because we have only formed an association on one of the models, a `Pet` has no restrictions on the number of `User` models it can belong to. We can change this and associate the `Pet` with exactly one `User` and the `User` with exactly one `Pet`.

```js
// user.js - A user may only have a single pet
{
  attributes: {
    firstName: 'string',
    lastName: 'string',

    // Add a reference to Pet
    pet: {
      model: 'pet'
    }
  }
}

// pet.js
{
  attributes: {
    breed: 'string',
    type: 'string',
    name: 'string',

    // Add a reference to User
    user: {
      model: 'user'
    }
  }
}
```

Now that both models know about each other you can query the association from both sides. To add an association to a model when creating a record you can use the named attribute you set in the model definition.

```js
Pet.create({
  breed: 'labrador',
  type: 'dog',
  name: 'fido',

  // Set the User's Primary Key to associate the Pet with the User.
  user: 123
})
.exec((err, pet) => { })
```

This will create a new `Pet` record with the `User` foreignKey set. It will allow you to query a `Pet` and retrieve their owners, but the `User` side of the association doesn't know about the `Pet`. To ensure you can query both ways the `User` record will need to be updated with the new `Pet` record. You can do this in many ways but a simple nested example may look like this:

```js
Pet.create({
  breed: 'labrador',
  type: 'dog',
  name: 'fido',

  // Set the User's Primary Key to associate the Pet with the User.
  user: 123
})
.exec((err, pet) => {
  if (err) // Handle Error

  User.update(123, { pet: pet.id }).exec((err, user) => { })
})
```

Now that the associations are created you can query the records and include the associated data. To do this the `populate` option is used. This will add a key to each model returned that contains an object with the corresponding record. Because we set the association on both sides above you could use `populate` on either side.

```js
Pet.find()
.populate('user')
.exec((err, pets) => {

  // The pets object would look something like the following
  // [{
  //   id: 1,
  //   breed: 'labrador',
  //   type: 'dog',
  //   name: 'fido',
  //   user: {
  //     id: 123,
  //     firstName: 'Foo',
  //     lastName: 'Bar',
  //     pet: 1
  //   }
  // }]

})
```

### One-to-One with Existing Tables

These one-to-one relationships will also work if you're using a legacy database. You'll have to specify a `tableName` attribute, along with appropriate `columnName`s for each field attribute.

In this example, PetBiz prefixes all of their tables and fields with `pb_`. So the Pet model becomes:

```js
{
  tableName: 'pb_pets'

  attributes: {
    id: {
      type: 'integer',
      primaryKey: true
    },
    breed: {
      type: 'string',
      columnName: 'pb_pet_breed'
    },
    animal: {
      type: 'string',
      columnName: 'pb_pet_species'
    },
    name: {
      type: 'string',
      columnName: 'pb_pet_name'
    },

    // And here we make the association:
    owner: {
      model: 'user'
    }
  }
}
```

Meanwhile, the `User` would look something like this:

```js
{
  tableName: 'pb_user'

  attributes: {
    id: {
      type: 'integer',
      primaryKey: true
    },
    firstName: {
      type: 'string',
      columnName: 'pb_owner_first'
    },
    lastName: {
      type: 'string',
      columnName: 'pb_owner_last'
    },

    // Add a reference to Pet
    pet: {
      model: 'pet'
    }
  }
}
```

With just these minor changes to the model, the queries described earlier should work the same.

<div id="one-to-many"></div>
## One-to-Many Associations

A one-to-many association states that a model can be associated with many other models. To build this association a virtual attribute is added to a model using the `collection` property. In a one-to-many association one side must have a `collection` attribute and the other side must contain a `model` attribute. This allows the many side to know which records it needs to get when a `populate` is used.

Because you may want a model to have multiple one-to-many associations on another model, a `via` key is needed on the `collection` attribute. This states which `model` attribute on the one side of the association is used to populate the records.

```js
// user.js - A user may have many pets
{
  attributes: {
    firstName: 'string',
    lastName: 'string',

    // Add a reference to Pets
    pets: {
      collection: 'pet',
      via: 'owner'
    }
  }
}

// pet.js - A pet may only belong to a single user
{
  attributes: {
    breed: 'string',
    type: 'string',
    name: 'string',

    // Add a reference to User
    owner: {
      model: 'user'
    }
  }
}
```

Now that the pets and users know about each other, they can be associated. To do this we can create or update a pet with the user's primary key for the `owner` value.

```js
Pet.create({
  breed: 'labrador',
  type: 'dog',
  name: 'fido',

  // Set the User's Primary Key to associate the Pet with the User.
  owner: 123
})
.exec((err, pet) => { })
```

Now that the `Pet` is associated with the `User`, all the pets belonging to a specific user can be populated by using the `populate` method.

```js
User.find()
.populate('pets')
.then(users => {
  // The users object would look something like the following
  // [{
  //   id: 123,
  //   firstName: 'Foo',
  //   lastName: 'Bar',
  //   pets: [{
  //     id: 1,
  //     breed: 'labrador',
  //     type: 'dog',
  //     name: 'fido',
  //     owner: 123
  //   }]
  // }]
})
```

<div id="many-to-many"></div>
## Many-to-Many Associations

A many-to-many association states that a model can be associated with many other models and vice-versa. Because both models can have many related models a new join table will need to be created to keep track of these relations.

The ORM will look at your models and if it finds that two models both have collection attributes that point to each other, it will automatically build up a join table for you.

Because you may want a model to have multiple many-to-many associations on another model a `via` key is needed on the `collection` attribute. This states which `model` attribute on the one side of the association is used to populate the records.

You will also need to add a `dominant` property on one side of the association. This allows the ORM to know which side it can write the join table to in the case of different connections.

Using the `User` and `Pet` example, let's look at how to build a schema where a `User` may have many `Pet` records and a `Pet` may have multiple owners.

```js
// user.js - A user may have many pets
{
  attributes: {
    firstName: 'string',
    lastName: 'string',

    // Add a reference to Pet
    pets: {
      collection: 'pet',
      via: 'owners',
      dominant: true
    }
  }
}

// A pet may have many owners
{
  attributes: {
    breed: 'string',
    type: 'string',
    name: 'string',

    // Add a reference to User
    owners: {
      collection: 'user',
      via: 'pets'
    }
  }
}
```

Now that the `User` and `Pet` models have been created and the join table has been setup automatically, we can start associating records and querying the join table. To do this, let's add a `User` and `Pet` and then associate them together.

There are two ways of creating associations when a many-to-many association is used. You can associate two existing records together or you can associate a new record to the existing record. To show how this is done we will introduce the special methods attached to a `collection` attribute: `add` and `remove`.

Both these methods are sync methods that will queue up a set of operations to be run when an instance is saved. If a primary key is used for the value on an `add`, a new record in the join table will be created linking the current model to the record specified in the primary key. However if an object is used as the value in an `add`, a new model will be created and then the primary key of that model will be used in the new join table record. You can also use an array of previous values.

### When Both Records Exist

```js
// Given a User with ID 2 and a Pet with ID 20

User.findOne(2).then(user => {
  // Queue up a record to be inserted into the join table
  user.pets.add(20)

  // Save the user, creating the new associations in the join table
  user.save(err => { })
})
```

### With A New Record

```js
User.findOne(2).then(user => {
  // Queue up a new pet to be added and a record to be created in the join table
  user.pets.add({ breed: 'labrador', type: 'dog', name: 'fido' })

  // Save the user, creating the new pet and associations in the join table
  user.save(err => { })
})
```

### With An Array of New Record

```js
// Given a User with ID 2 and a Pet with ID 20, 24, 31

User.findOne(2).then(user => {
  // Queue up a record to be inserted into the join table
  user.pets.add([ 20, 24, 31 ])

  // Save the user, creating the new pet and associations in the join table
  user.save(err => { })
})
```

Removing associations is just as easy using the `remove` method. It works the same as the `add` method except it only accepts primary keys as a value. The two methods can be used together as well.

```js
User.findOne(2).then(user => {
  // Queue up a new pet to be added and a record to be created in the join table
  user.pets.add({ breed: 'labrador', type: 'dog', name: 'fido' })

  // Queue up a join table record to remove
  user.pets.remove(22)

  // Save the user, creating the new pet and syncing the associations in the join table
  user.save(err => { })
})
```

<div id="dominance"></div>
## Dominance

Take a look to the following ontology:

```js
// user.js
{
  attributes: {
    email: 'string',
    wishlist: {
      collection: 'product',
      via: 'wishlistedBy'
    }
  }
}
```

```js
// product.js
{
  connection: 'ourRedis',
  attributes: {
    name: 'string',
    wishlistedBy: {
      collection: 'user',
      via: 'wishlist'
    }
  }
}
```

### The Problem

It's easy to see what's going on in this cross-adapter relationship. There's a many-to-many ( `N->...` ) relationship between users and products.  In fact, you can imagine a few other relationships (e.g. purchases) which might exist, but since those are probably better-represented using a middleman model, I went for something simple in this example.

Anyways, that's all great... but where does the relationship resource live?  "ProductUser", if you'll pardon the SQL-oriented nomenclature. We know it'll end up on one side or the other, but what if we want to control which database it ends up in?

> **IMPORTANT NOTE**
>
> This is only a problem because both sides of the association have a `via` modifier specified. In the absence of `via`, a collection attribute always behaves as `dominant: true`. See the FAQ below for more information.

### The Solution

Eventually, it may even be possible to specify a 3rd connection/adapter to use for the join table. For now, we'll focus on choosing one side or the other.

We address this through the concept of "dominance."  In any cross-adapter model relationship, one side is assumed to be dominant. It may be helpful to think about the analogy of a child with multinational parents who must choose one country or the other for her [citizenship](http://en.wikipedia.org/wiki/Japanese_nationality_law)

Here's the ontology again, but this time we'll indicate the MySQL database as the "dominant".  This means that the "ProductUser" relationship "table" will be stored as a MySQL table.

```js
// user.js
{
  connection: 'ourMySQL',
  attributes: {
    email: 'string',
    wishlist: {
      collection: 'product',
      via: 'wishlistedBy',
      dominant: true
    }
  }
};
```

```js
// product.js
module.exports = {
  connection: 'ourRedis',
  attributes: {
    name: 'string',
    wishlistedBy: {
      collection: 'user',
      via: 'wishlist'
    }
  }
}
```

### Choosing a "dominant"

Several factors may influence your decision:

- If one side is a SQL database, placing the relationship table on that side will allow your queries to be more efficient, since the relationship table can be joined before the other side is communicated with. This reduces the number of total queries required from 3 to 2.
- If one connection is much faster than the other, all other things being equal, it probably makes sense to put the connection on that side.
- If you know that it is much easier to migrate one of the connections, you may choose to set that side as `dominant`.  Similarly, regulations or compliance issues may affect your decision as well. If the relationship contains sensitive patient information (for instance, a relationship between `Patient` and `Medicine`) you want to be sure that all relevant data is saved in one particular database over the other (in this case, `Patient` is likely to be `dominant`).
- Along the same lines, if one of your connections is read-only (perhaps `Medicine` in the previous example is connected to a read-only vendor database), you won't be able to write to it, so you'll want to make sure your relationship data can be persisted safely on the other side.

### FAQ

#### What if one of the collections doesn't have `via`?

If a `collection` association does not have a `via` property, it is automatically `dominant: true`.

#### What if neither collection has `via`?

If neither `collection` association has `via`, then they are not related.  Both are `dominant`, because they are separate relationship tables!

#### What about `model` associations?

In all other types of associations, the `dominant` property is prohibited.  Setting one side to `dominant` is only necessary for associations between two models which have an attribute like: `{ via: '...', collection: '...' }` on both sides.

#### Can a model be dominant for one attribute and not another?
Keep in mind that a model is "dominant" only in the context of a particular relationship.  A model may be dominant in one or more relationships (attributes) while simultaneously NOT being dominant in other relationships (attributes).

e.g. if a `User` has a collection of toys called `favoriteToys` via `favoriteToyOf` on the `Toy` model, and `favoriteToys` on `User` is `dominant: true`, `Toy` can still be dominant in other ways.  So `Toy` might also be associated to `User` by way of its attribute, `designedBy`, for which it is `dominant: true`.

#### Can both models be dominant?

No. If both models in a cross-adapter/cross-connection, many-to-many association set `dominant: true`, an error is thrown before lift.

#### Can neither model be dominant?

Sort of... If neither model in a cross-adapter/cross-connection, many-to-many association sets `dominant: true`, a warning is displayed before lift, and a guess will be made automatically based on the characteristics of the relationship.  For now, that just means an arbitrary decision based on alphabetical order :)

#### What about non-cross-adapter associations?

The `dominant` property is silently ignored in non-cross-adapter/cross-connection associations.  We're assuming you might be planning on breaking up the schema across multiple connections eventually, and there's no reason to prevent you from being proactive.  Plus, this reserves additional future utility for the "dominant" option down the road.
