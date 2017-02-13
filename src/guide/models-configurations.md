---
title: Model Configuration
type: guide
order: 26
---

## Configuration

You can define certain top level properties on a per-model basis. These will define how your schema is synced with the datastore and allows you to turn off default behaviour.

### identity

A required property on each model which describes the name of the model. This must be unique and it must be in lower case.

```js
{

  identity: 'foo'

}
```

To make your life easier, Stellar inject this property automatically, based on the filename of the model that is loading.

### connection

A required property on each model that describes which connection queries will be run on. You can use either a string or an array for the value of this property. If an array is used your model will have access to methods defined on both adapters in the connections. They will inherit from right to left giving the adapter from the first connection priority in adapter methods.

For example, if you defined connections using both `sails-postgresql` and `sails-mandrill` and the `sails-mandrill` adapter exposes a `send` method, your model will contain all the CRUD methods exposed from `sails-postgresql` as well as a `send` method which will be run on the mandrill adapter.

```js
// String Format
const newModel = {

  connection: 'my-local-postgresql'

}

// Array Format
const newModel = {

  connection: [ 'my-local-postgresql', 'sails-mandrill' ]

}
```

When the connection property isn't defined the global one will be used. To configure that you must set the `models.defaultConnection` config.

### migrate

Sets the schema to automatically `alter` the schema, `drop` the schema or make no changes (`safe`). Default: `alter`

```js
const newModel = {

  migrate: 'alter'

}
```

It is **extremely important** to set the `migrate` property to `safe` in your models when working with existing databases. If you do not to this, you will very likely **lose data** and do other terrible things as it tries to automatically adjust the schema.

### autoPK

A flag to toggle the automatic primary key generation. Default: `true`.

If turned off no primary key will be created by default and one will need to be defined.

```js
const newModel = {

  autoPK: false

}
```

### autoCreatedAt

A flag to toggle the automatic timestamp for createdAt. Default: `true`.

```js
const newModel = {

  autoCreatedAt: false

}
```

Note that if this flag is set and the `createdAt` property is supplied on create that value will be used to create the record in the datastore.

### autoUpdatedAt

A flag to toggle the automatic timestamp for updatedAt. Default: `true`.

```js
const newModel = {

  autoUpdatedAt: false

}
```

Note that if this flag is set and the `updatedAt` property is supplied on update, that value will be used to create the record in the datastore.

### schema

A flag to toggle schemaless or schema mode in databases that support schemaless data structures. If turned off this will allow you to store arbitrary data in a record. If turned on, only attributes defined in the model's attributes object will be allowed to be stored.

For adapters that don't require a schema (such as Mongo or Redis) the default setting is to be schemaless.

```js
const newModel = {

  schema: true

}
```

### tableName

You can define a custom table or collection name on your adapter by adding a `tableName` attribute. If no table name is supplied it will use the identity as the table name when passing it to an adapter.

```js
const newModel = {

  tableName: 'my-legacy-table-name'

}
```

## Global Configurations

__Must__ of the configurations that you can see above, they are able to be changed in all models simply setting a global configuration, as you can see on the follow example:

```js
// production configurations
exports.production = {
  models: api => {
    return {
      adapters: {
        'mongodb': 'sails-mongo'
      },
      connections: {
        mongodb: {
          // (...)
        }
      },
      defaults: {
        migrate: 'safe'
      },
      defaultConnection: 'mongodb'
    }
  }
}
```

Setting the `models.defaults` you can overwrite the default values and set them for what you need.
