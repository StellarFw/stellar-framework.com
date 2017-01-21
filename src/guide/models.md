---
title: Introduction
type: guide
order: 20
---

The model system included with Stellar provides a straight-forward, schema-based solution to model your application data. It includes built-in type casting, validation, query building, business logic hooks and more, out of the box. All to work with you database. This set of features that we provide are only possible because we chose [Waterline](https://github.com/balderdashy/waterline) to be our primary ORM.

Each database collection has a corresponding "Model" which is used to interact with that collection. Models allow you to query for data in your collections, as well as insert new records into the collection.

Before getting started, be sure to configure a database connection in `config/database.js`. For more information on configuring your database, check out the documentation.

## First steps

### Configuration

The database configuration for your application is located at `config/database.js`, but you can choose some other name, we use this to better know what configs are inside the file. If you do not configure it an in-memory database will be used, this is done to provide you a out of the box way to start developing your API without hurry about configurations and is a great way to mock or database on a testing environment.

So, just for example we will create a connection with a MongoDB database.

First of all we need to add the database adapter as an dependency, for that you use the `npmDependencies` property on the `manifest.json` file of your package.

```json
{
    "id": "private",
    "name": "Private Module",
    "version": "1.0.0",
    "description": "This module exists to store the private project actions and tasks",
    "npmDependencies": {
      "sails-mongo": "0.12.2"
    }
}
```

The next step is configure the connection on the `config/database.js`, or otehr filename that you want:

```js
exports.production = {
  models: api => {
    return {
      adapters: {
        'mongodb': 'sails-mongo'
      },

      connections: {
        mongodb: {
          adapter: 'mongodb',
          url: 'mongodb://jarvis:somepassword@example.com:27017/awesomeDb'
        }
      },

      defaults: {
        migrate: 'safe'
      },

      defaulConnection: 'mongodb'
    }
  }
}
```

So, let's stop for a while an check what we have done here. First of all, we specify a new adapter using the package name that we add before on the dependencies, we call our adapter of "mongodb", but you can give it some other name. Then we create a new connection using the standard connection string, which is already known for the mongo users.

> NOTE: on the connection, with the exception of the `adapter`, the other key-value pairs are all configs related with the chosen adapter. You can see the adapter documentation to see what you need put here.

Finally, we set the new connection as the default one, and done! No we are ready to go.

Note that you need to install the adapter before run, for that you can start the server using the `--update` options like this:

```bash
stellar run --update
```

### Defining Models

To get started, let's create an model. Models live in the `models` directory on the modules roots.

The easiest way to create a model instance is using the `makeModel` command:

```bash
stellar makeModel User --module=authentication
```

If you would like to generate a CRUD action when you generate the model, you may use the `--crud` option:

```bash
stellar makeModel User --module=authentication --crud
```

> NOTE: the generated code uses the function syntax. You can see more about that on the next subsection.

All the models are loaded into memory when a new Stellar instance is started, so you have a global place where all the models lives (`api.models`). Ahead will be able to see how to get a model an use it on your code.

### Model Conventions

Now, let's look at an example `Content` model, which we will use to retrieve and store information from our `contents` database collection:

```js
'use strict'

exports.default = {
  title: 'string',
  content: 'string',
  source: 'string',
  tags: 'array'
}
```

Note that you can use a function instead of an `Object`, to define more advanced models.

```js
exports.default = api => {
  // create a new model
  const newModel = {
    attributes: {
      // TODO: add fields to this model
    }
  }

  return newModel
}
```

## Extend Models

For now, there is no way to replace or modify already created models. So, in order to manipulate (add, modify or remove) fields, Stellar provides a custom event on the model insertion. The event name is `core.models.add.{name}`, `name` is dynamic and is replaced with the model name. Using this naming convention we don't need to call all the listeners who modify models, instead of that we just call the right listeners for that specific model.

The `core.models.add.{name}` event receives an instance of the Model (`model`) as you can see bellow. The follow example shows how to extend a model. In this case we are adding two new fields to the `user` model:

```js
exports.editUserModel = {
  event: 'core.models.add.user',
  description: 'This adds the address and the phone fields to the user model',

  run (api, params, next) {
    // get the user model
    const User = params.model

    // add the new two fields
    User.attributes = Object.assign(User.attributes, {
      address: { type: 'string', defaultsTo: null },
      phone: { type: 'string', defaultsTo: null }
    })

    // finish the event execution
    next()
  }
}
```

> Note that the `user` model is owned by another module (for example, the [Authentication module](https://github.com/stellarFw/Identify)).
