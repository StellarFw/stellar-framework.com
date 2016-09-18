---
title: Models
type: guide
order: 4
---

# Introduction

The model system included with Stellar provides a straight-forward, schema-based solution to model your application data. It includes built-in type casting, validation, query building, business logic hooks and more, out of the box. All to work with you database.

Each database collection has a corresponding "Model" which is used to interact with that collection. Models allow you to query for data in your collections, as well as insert new records into the collection.

Before getting started, be sure to configure a database connection in `config/database.js`. For more information on configuring your database, check out the documentation.

> Note: For now, Stellar only support MongoDB servers.

## Configuration

The database configuration for your application is located at `config/database.js`, but you can choose some other name, we use this to better know what configs are inside the file. If you do not configure it an in-memory database will be used, this is done to provide to you a out of the box way to start developing your API without hurry about configurations and is a mock for testing environment.

There is two parameter that you can configure:

- **`connectionString`**: The connection string to be passed to connection package;
- **`pkg`**: The connection package to use in the connection with the database. This can assume two values (`mongoose`, `mockgose`).

The follow code show a example config to connect with a remote MongoDB server on the MLab servers, in the development environment:

```javascript
'use strict'

// use a remote MongoDB server on development
exports.development = {
  models: api => {
    return {
      connectionString: 'mongodb://exampleUser:examplePass@dz010866.mlab.com:19876/myOpDatabase',
      pkg: 'mongoose'
    }
  }
}
```

## Defining Models

To get started, let's create an model. Models live in the `models` directory on the modules root.

The easiest way to create a model instance is using the `makeModel` command:

```shell
stellar makeModel User --module=authentication
```

If you would like to generate a CRUD action when you generate the model, you may use the --crud option:

```shell
stellar makeModel User ---module=authentication --crud
```

All the models are loaded into memory when a new Stellar instance is started, so you have a global place where all the models living (`api.models`). Ahead will be able to see how to get a model an use it on your code.

## Model Conventions

Now, let's look at an example `Content` model, which we will use to retrieve and store information from our `contents` database collection:

```javascript
'use strict'

exports.default = {
  title:   String,
  content: String,
  source:  String,
  tags:    [ String ]
}
```

> Note: You must use the Mongoose syntax to define your models.

For more advanced models you can use a function instead of an `Object`:

```javascript
'use strict'

exports.default = (api, mongoose) => {
  // get Schema type
  let Schema = mongoose.Schema

  // return the schema
  return new Schema({
    _creator: { type: Schema.Types.ObjectId, ref: 'question' },
    content: String,
    user: Schema.Types.Mixed
  }, {
    timestamps: true
  })
}
```

## Retrieving Models

Once you created a model, you are ready to start retrieving data from your database. For example:

```javascript
api.models.get('question').find({}, (err, resources) => {
  // so something...
})
```

You can define some search parameters like this:

```javascript
api.models.get('question').find({ tile: new RegExp('^Node\s*', "i") }, (err, resources) => {
  // so something...
})
```

## Retrieving Single Models

Of course, in addition to retrieving all of the records for a given collection, you may also retrieve single records using `findOne`, `findById`. Instead of returning a collection of models, these method return a single model instance.

```javascript
// retrieve a model by its id
api.models.get('question').findById('507f1f77bcf86cd799439011', (err, resource) => {
  // do something...
})

// retrieve the first model matching the query constraints...
api.models.get('question').findOne({ active: true }, (err, resource) => {
  // do something...
})
```

When the model are not found the `resource` variable is `null`.

## Inserting & Updating Models

### Inserts

To create a new record in the database, simple create a new model instance, set attributes on the model, then call the save method:

```javascript
exports.createQuestion = {
  name: 'createQuestion',
  description: 'Create a new question',

  run: (api, action, next) => {
    const QuestionModel = api.models.get('question')

    let question = new QuestionModel()

    question.title = action.params.title

    question.save()
  }
}
```

In this example, we simply assign the title parameter from the incoming request to the name attribute of the `Question` model instance. When we call the save method, a record will be inserted into the database.

### Updates

The save method may also be used to update models that already exist in the database. To update a model, you should retrieve it, set any attributes you wish to update, and then call the save method.

```javascript
let question = QuestionModel.findById('507f1f77bcf86cd799439011')

question.content = 'New Question Content'

question.save()
```

You can also rewrite the code above using the `findOneAndUpdate` method:

```javascript
QuestionModel.findOneAndUpdate({ _id: '507f1f77bcf86cd799439011' }, { content: 'New Question Content' })
```

#### Mass Update

Updates can also be performed against any number of models that match a given query. In this example, all question that are `active` will be marked as inactive:

```javascript
QuestionModel.update({ active : true }, { active: false }, { multi: true })
```

## Deleting Models

To delete a model, call the delete method on a model instance:

```javascript
QuestionModel.findByIdAndRemove('507f1f77bcf86cd799439011')
```
