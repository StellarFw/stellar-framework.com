---
title: Queries
type: guide
order: 27
---

The ORM Query Interface allows you to interact with your models the same way no matter which adapter they are using. This means you can use the same query language whether your data lives in MySQL, MongoDB, Redis, etc.

The Query Interface exposes the following methods:

- `findOne`
- `find`
- `create`
- `update`
- `destroy`
- `findOrCreate`
- `count`

See [Query Methods](#Query-Methods) for more information on their use.

## Simple Querying

The ORM exposes a normalized language for finding records no matter which datastore the records live in. The following options are available on all `find` and `findOne` queries.

Each option will return an instance of the deferred object used to create the query, so options can be chained together to create complex queries.

See [Query Language](#Query-Language) for more information on the options available in the query language.

```javascript
User.find()
.where({ name: { contains: 'foo' }})
.populate('animals', { type: 'dog', limit: 10 })
.skip(20)
.limit(10)
.exec((err, users) => { })
```

For convenience, promises are supported if you choose to use them. Promises use the [Bluebird library](http://bluebirdjs.com), so anything you do after the first `then` call (or `spread`, or `catch`), will be a complete Bluebird promise object. Remember, you must end the query somehow (by calling then or one of the other functions) in order to complete the database request.

```javascript
User.findOne()
.where({ id: 2 })
.then(user => {
  const comments = Comment.find({ userId: user.id })

  return [ user.id, user.friendsList, comments ]
})
.spread((userId, friendsList, comments) => {

})
.catch(err => {
  // An error occured
})
```

### .where()

`where` is the primary criteria for your query. Here you specify what you would like to search for using any of the supported [Query Language](#Query-Language).

|     Description     | Accepted Data Types | Required ? |
|---------------------|---------------------|------------|
|  Criteria Object    |      `{}`           | Yes        |


```javascript
User.find()
.where({ name: { startsWith: 'w' }})
.exec((err, results) => {})
```

### .populate()

`populate` is used with associations to include any related values specified in a model definition. If a `collection` attribute is defined in a many-to-many, one-to-many or many-to-many-through association the `populate` option also accepts a full criteria object. This allows you to filter associations and run `limit` and `skip` on the results.

|     Description     | Accepted Data Types | Required ? |
|---------------------|---------------------|------------|
|  Attribute Name     |      `string`       | Yes        |
|  Criteria Object    |      `{}`           | No         |

```javascript
// Simple Population
User.find()
.populate('foo')
.exec((err, users) => { })
```

```javascript
// Collection Filtering
User.find()
.populate('foo', { type: 'bar', limit: 20 })
.exec((err, users) => { })
```

### .limit()

`limit` will restrict the number of records returned by the query.

|     Description     | Accepted Data Types | Required ? |
|---------------------|---------------------|------------|
|  Number to Return   |      `int`          | Yes        |

```javascript
User.find()
.limit(10)
.exec((err, users) => { })
```

### .skip()

`skip` will skip over n results when returning the results.

|     Description     | Accepted Data Types | Required ? |
|---------------------|---------------------|------------|
|  Number to Skip     |      `int`          | Yes        |

```javascript
User.find()
.skip(10)
.exec((err, users) => { })
```

### .paginate()

When `skip` and `limit` are put together, they create the ability to paginate through records as you would for pages. For example, if I wanted 'page 2' of a given record set, and I only want to see 10 records at a time, I know that I need to `skip(10)` and `limit(10)` like so:

```javascript
User.find()
.skip(10)
.limit(10)
.exec((err, users) => { })
```

But, while we are thinking in terms of pagination, or pages, it might be easier to use the paginate helper:

```javascript
User.find()
.paginate({ page: 2, limit: 10 })
.exec((err, users) => { })
```

Paginate has several options:

- `paginate()` defaults options to `{ page: 0, limit: 10 }`.
- `paginate({page: 2})` uses `{ page: 2, limit: 10 }` as the options.
- `paginate({limit: 20})` uses `{ page: 0, limit: 20 }` as the options.
- `paginate({page: 1, limit: 20})` uses `{ page: 1, limit: 20 }` as the options.

### .sort()

`sort` will return a sorted set of values. Simply specify an attribute name for natural (ascending) sort, or specify an `asc` or `desc` flag for ascending or descending orders respectively.

```javascript
User.find()
.sort('roleId asc')
.sort({ createdAt: 'desc' })
.exec((err, users) => { })
```

### .exec()

`exec` will run the query and return the results to the supplied callback. It should be the last method in the chain.

|     Description     | Accepted Data Types | Required ? |
|---------------------|---------------------|------------|
|  Callback           |      `function`     | Yes        |

```javascript
User.find()
.exec((err, users) => { })
```

## Query Language

The criteria objects are formed using one of four types of object keys. These are the top level keys used in a query object. It is loosely based on the criteria used in MongoDB with a few slight variations.

Queries can be built using either a `where` key to specify attributes, which will allow you to also use query options such as `limit` and `skip` or if `where` is excluded the entire object will be treated as a `where` criteria.

```javascript
Model.find({ where: { name: 'foo' }, skip: 20, limit: 10, sort: 'name DESC' });

// OR

Model.find({ name: 'foo' })
```

### Key Pairs

A key pair can be used to search records for values matching exactly what is specified. This is the base of a criteria object where the key represents an attribute on a model and the value is a strict equality check of the records for matching values.

```javascript
Model.find({ name: 'walter' })
```

They can be used together to search multiple attributes.

```javascript
Model.find({ name: 'walter', state: 'new mexico' })
```

### Modified Pairs

Modified pairs also have model attributes for keys but they also use any of the supported criteria modifiers to perform queries where a strict equality check wouldn't work.

```javascript
Model.find({
  name : {
    'contains' : 'alt'
  }
})
```

> You can see more about this mater on a [section above](#Criteria-Modifiers).

### In Pairs

IN queries work similarly to MySQL 'in queries'. Each element in the array is treated as 'or'.

```javascript
Model.find({
  name : ['Walter', 'Skyler']
});
```

### Not-In Pairs

Not-In queries work similar to `in` queries, except for the nested object criteria.

```javascript
Model.find({
  name: { '!' : ['Walter', 'Skyler'] }
});
```

### Or Pairs

Performing `OR` queries is done by using an array of query pairs. Results will be returned that match any of the criteria objects inside the array.

```javascript
Model.find({
  or : [
    { name: 'walter' },
    { occupation: 'teacher' }
  ]
})
```

## Criteria Modifiers

The following modifiers are available to use when building queries.

- `'<'` / `'lessThan'`
- `'<='` / `'lessThanOrEqual'`
- `'>'` / `'greaterThan'`
- `'>='` / `'greaterThanOrEqual'`
- `'!'` / `'not'`
- `'like'`
- `'contains'`
- `'startsWith'`
- `'endsWith'`


### '<' / 'lessThan'

Searches for records where the value is less than the value specified.

```javascript
Model.find({ age: { '<': 30 }})
```

### '<=' / 'lessThanOrEqual'

Searches for records where the value is less or equal to the value specified.

```javascript
Model.find({ age: { '<=': 21 }})
```

### '>' / 'greaterThan'

Searches for records where the value is more than the value specified.

```javascript
Model.find({ age: { '>': 18 }})
```

### '>=' / 'greaterThanOrEqual'

Searches for records where the value is more or equal to the value specified.

```javascript
Model.find({ age: { '>=': 21 }})
```

### '!' / 'not'

Searches for records where the value is not equal to the value specified.

```javascript
Model.find({ name: { '!': 'foo' }})
```

### 'like'

Searches for records using pattern matching with the `%` sign.

```javascript
Model.find({ food: { 'like': '%beans' }})
```

### 'contains'

A shorthand for pattern matching both sides of a string. Will return records where the value contains the string anywhere inside of it.

```javascript
Model.find({ class: { 'contains': 'history' }})

// The same as

Model.find({ class: { 'like': '%history%' }})
```

### 'startsWith'

A shorthand for pattern matching the right side of a string. Will return records where the value
starts with the supplied string value.

```javascript
Model.find({ class: { 'startsWith': 'american' }})

// The same as

Model.find({ class: { 'like': 'american%' }})
```

### 'endsWith'

A shorthand for pattern matching the left side of a string. Will return records where the value
ends with the supplied string value.

```javascript
Model.find({ class: { 'endsWith': 'can' }})

// The same as

Model.find({ class: { 'like': '%can' }})
```

### 'Date Ranges'

You can do date range queries using the comparison operators.

```javascript
Model.find({ date: { '>': new Date('2/4/2014'), '<': new Date('2/7/2014') } })
```

## Query Options

Query options allow you refine the results that are returned from a query. The current options available are:

- `limit`
- `skip`
- `sort`
- `select`

### Limit

Limits the number of results returned from a query.

```javascript
Model.find({ where: { name: 'foo' }, limit: 20 })
```

### Skip

Returns all the results excluding the number of items to skip.

```javascript
Model.find({ where: { name: 'foo' }, skip: 10 })
```

### Pagination

`skip` and `limit` can be used together to build up a pagination system.

```javascript
Model.find({ where: { name: 'foo' }, limit: 10, skip: 10 })
```

### Sort

Results can be sorted by attribute name. Simply specify an attribute name for natural (ascending) sort, or specify an `asc` or `desc` flag for ascending or descending orders respectively.

```javascript
// Sort by name in ascending order
Model.find({ where: { name: 'foo' }, sort: 'name' })

// Sort by name in descending order
Model.find({ where: { name: 'foo' }, sort: 'name DESC' })

// Sort by name in ascending order
Model.find({ where: { name: 'foo' }, sort: 'name ASC' })

// Sort by binary notation
Model.find({ where: { name: 'foo' }, sort: { 'name': 1 }})

// Sort by multiple attributes
Model.find({ where: { name: 'foo' }, sort: { name:  1, age: 0 }})
```

## Query Methods

Every model will have a set of query methods exposed on it to allow you to interact with the database in a normalized fashion. These are known as the CRUD (Create-Read-Update-Delete) methods and is the primary way of interacting with your data.

There are also a special set of queries known as *dynamic queries*. These are special class methods that are dynamically generated. We call them dynamic finders. They perform many of the same functions as the other class methods but you can call them directly on an attribute in your model.

> For most class methods, the callback parameter is optional and if one is not supplied, it will return a chainable object.

### CRUD Methods

#### .find( `criteria`, [`callback`] )

`find` will return an array of records that match the supplied criteria. Criteria can be built using the [Query Language](#Query-Language).

|    Description     | Accepted Data Types             | Required ? |
|--------------------|---------------------------------|------------|
|   Find Criteria    |   `{}`,`[{}]`, `string`, `int`  |   Yes      |
|     Callback       |   `function`                    |   No       |

```javascript
User.find({ name: 'Walter Jr' })
.exec((err, users) => { })
```

> NOTE: Any string arguments passed must be the ID of the record. This method will ALWAYS return records in an array. If you are trying to find an attribute that is an array, you must wrap it in an additional set of brackets otherwise the ORM will think you want to perform an inQuery.

#### .findOne( `criteria`, [`callback`] )

`findOne` will return an object with the first matching result in the datastore.

|    Description     | Accepted Data Types             | Required ? |
|--------------------|---------------------------------|------------|
|   Find Criteria    |   `{}`,`[{}]`, `string`, `int`  |   Yes      |
|     Callback       |   `function`                    |   No       |

```javascript
User.findOne({ name: 'Walter Jr' })
.exec((err, user) => { })
```

> NOTE: Any string arguments passed must be the ID of the record. If you are trying to find an attribute that is an array, you must wrap it in an additional set of brackets otherwise Waterline will think you want to perform an inQuery.

#### .create( `criteria`, [`callback`] )

`create` will attempt to create a new record in the datastore. If the data is valid and passes all validations it will be sent to the adapters `create` method.

|     Description     | Accepted Data Types | Required ? |
|---------------------|---------------------|------------|
|  Records to Create  |      `{}`, `[{}]`   | Yes        |
|     Callback        | `function`          | No         |

```javascript
User.create({
  name: 'Walter Jr'
})
.exec((err, user) => { })
```

#### .findOrCreate( `search criteria`, [`values`, `callback`] )

`findOrCreate` will return a single record if one was found or created, or an array of records if multiple get found/created via the supplied criteria or values. Criteria can be built using the [Query Language](Query-Language).

|    Description     | Accepted Data Types             | Required ? |
|--------------------|---------------------------------|------------|
|   Find Criteria    |   `{}`,`[{}]`, `string`, `int`  |   Yes      |
|   Creation Values   |   `{}`,`[{}]`                   |   No      |
|     Callback       |   `function`                    |   No       |

```javascript
User.findOrCreate({ name: 'Walter Jr' })
.exec((err, users) => {
//either user(s) with the name 'Walter Jr' get returned or
//a single user gets created with the name 'Walter Jr' and returned
})
```

> NOTE: Any string arguments passed must be the ID of the record. This method can return a single record or an array of records. If a model is not found and creation values are omitted, it will get created with the supplied criteria values.


> WARNING: Unless an adapter implements its own version of `findOrCreate`, `findOrCreate` will do the `find` and `create` calls in two separate steps (not transactional). In a high frequency scenario it's possible for duplicates to be created if the query field(s) are not indexed.

#### .update( `search criteria` , `values` , [`callback`] )

`update` will attempt to update any records matching the criteria passed in. Criteria can be built using the [Query Language](Query-Language).

|    Description     | Accepted Data Types             | Required ? |
|--------------------|---------------------------------|------------|
|   Find Criteria    |   `{}`,`[{}]`, `string`, `int`  |   Yes      |
|   Updated Values   |   `{}`,`[{}]`                   |   Yes      |
|     Callback       |   `function`                    | No         |

```javascript
User.update({ name: 'Walter Jr' }, { name: 'Flynn' })
.exec((err, users) => { })
```

> NOTE: Although you may pass `.update()` an object or an array of objects, it will always return an array of objects. Any string arguments passed must be the ID of the record. If you specify a primary key (e.g. `7` or `50c9b254b07e040200000028`) instead of a criteria object, any `.where()` filters will be ignored.

#### .destroy( `criteria` , [`callback`] )

`destroy` will destroy any records matching the provided criteria. Criteria can be built using the [Query Language](Query-Language).

|    Description     | Accepted Data Types             | Required ? |
|--------------------|---------------------------------|------------|
|   Find Criteria    |   `{}`,`[{}]`, `string`, `int`  |   Yes      |
|     Callback       |   `function`                    |   No       |

```javascript
User.destroy({ name: 'Flynn' })
.exec(err => { })
```

> NOTE: If you want to confirm the record exists before you delete it, you must first perform a find(). Any string arguments passed must be the ID of the record.

#### .query( `query`, `[data]`, `callback` )

Some adapters, such as [sails-mysql](https://github.com/balderdashy/sails-mysql) and [sails-postgresql](https://github.com/balderdashy/sails-postgresql), support the `query` function which will run the provided RAW query against the database. This can sometimes be useful if you want to run complex queries and performance is very important.

|    Description     | Accepted Data Types             | Required ? |
|--------------------|---------------------------------|------------|
|     Query          |   `string`                      |   Yes      |
|     Data           |   `array`                       |   No       |
|     Callback       |   `function`                    |   Yes      |

```javascript
const title = "The King's Speech";

Movie.query('SELECT * FROM movie WHERE title = $1', [title], (err, results) => {
  // using sails-postgresql
  console.log('Found the following movie: ', results.rows[0])

  // using sails-mysql
  console.log('Found the following movie: ', results[0])
})
```

> NOTE: The type of the results returned depend on your adapter: sails-mysql returns an array of objects and sails-postgresql returns an object containing metadata and the actual results within a 'rows' array. This function does currently not support promises.

### Aggregates

Some adapters (including [sails-mysql](https://github.com/balderdashy/sails-mysql) and [sails-postgresql](https://github.com/balderdashy/sails-postgresql)) support aggregate queries using specific grouping and aggregation methods. Currently `groupBy` for grouping and `max`, `min`, `sum`, and `average` for aggregation are supported. For SQL based adapters if `groupBy` is used then at least one aggregate must be specified as well, and only the aggregated and grouped attributes will be returned in the results.

#### .groupBy( `attribute` or `expression` )

`groupBy` will group results by the specified attribute or expression (for SQL adapters that support expressions).

|    Description        | Accepted Data Types             | Required ? |
|-----------------------|---------------------------------|------------|
|Attribute or Expression|   `string`                      |   Yes      |

```javascript
// Find the highest grossing movie by genre.
Movie.find()
	.groupBy('genre')
	.max('revenue')
	.then(results => {
		// Max revenue for the first genre.
		results[0].revenue
	})

// Find the highest grossing movie by year.
Movie.find()
	.groupBy('to_char("movie"."releaseDate", \'YYYY\')')
	.max('revenue')
	.then(results => {
		// Max revenue for the first year.
		results[0].revenue;

		// The first year.
		results[0].group0
	})
```

> NOTE: As specified by the [Waterline SQL Interface](https://github.com/balderdashy/waterline-adapter-tests/tree/master/interfaces/sql), along with attributes SQL expressions are accepted by the `groupBy` method. This allows you to create queries that group by month or year on a datetime field. Since expressions don't provide an attribute to serve as a key in the returned results the `groupBy` method will key each grouped attribute with `group0` where `0` is the index of the `groupBy` method call containing the expression.

#### .max( `attribute` )

`max` will find the maximum value for the given attribute.

|    Description     | Accepted Data Types             | Required ? |
|--------------------|---------------------------------|------------|
|   Attribute        |   `string`                      |   Yes      |

```javascript
// Find the highest grossing movie by genre.
Movie.find()
	.groupBy('genre')
	.max('revenue')
	.then(results => {
		// Max revenue for the first genre.
		results[0].revenue
	})
```

#### .min( `attribute` )

`min` will find the minimum value for the given attribute.

|    Description     | Accepted Data Types             | Required ? |
|--------------------|---------------------------------|------------|
|   Attribute        |   `string`                      |   Yes      |

```javascript
// Find the lowest grossing movie by genre.
Movie.find()
	.groupBy('genre')
	.min('revenue')
	.then(results => {
		// Min revenue for the first genre.
		results[0].revenue
	})
```

#### .sum( `attribute` )

`sum` will find the summed total for the given attribute.

|    Description     | Accepted Data Types             | Required ? |
|--------------------|---------------------------------|------------|
|   Attribute        |   `string`                      |   Yes      |

```javascript
// Find the movie revenue by genre.
Movie.find()
	.groupBy('genre')
	.sum('revenue')
	.then(results => {
		// Total revenue for the first genre.
		results[0].revenue
	})
```

#### .average( `attribute` )

`average` will find the average value for the given attribute.

|    Description     | Accepted Data Types             | Required ? |
|--------------------|---------------------------------|------------|
|   Attribute        |   `string`                      |   Yes      |

```javascript
// Find the average movie revenue by genre.
Movie.find()
	.groupBy('genre')
	.average('revenue')
	.then(results => {
		// Average revenue for the first genre.
		results[0].revenue;
	})
```
