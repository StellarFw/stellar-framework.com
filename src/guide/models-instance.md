---
title: Instance and Class Methods
type: guide
order: 25
---

## Instance methods

You can attach instance methods to a model which will be available on any record returned from a query. These are defined as functions in your model attributes.

```javascript
{
  attributes: {
    firstName: 'string',
    lastName: 'string',
    fullName () {
      return this.firstName + ' ' + this.lastName
    }
  }
}
```

### toObject/toJSON

The `toObject()` method will return the currently set model values only, without any of the instance methods attached. Useful if you want to change or remove values before sending to the client.

However we provide an even easier way to filter values before returning to the client by allowing you to override the `toJSON()` method in your model.

Example of filtering a password in your model definition:

```javascript
{
  attributes: {
    name: 'string',
    password: 'string',

    // Override toJSON instance method to remove password value
    toJSON () {
      let obj = this.toObject()
      delete obj.password
      return obj
    }
  }
}
```

## Class Methods

"Class" methods are functions available at the top level of a model. They can be called anytime after you get a model instance.

These are useful if you would like to keep model logic in the model and have reusable functions available.

```javascript
// example.js - just an example model
{
  attributes: { },

  // A "class" method
  method1 () { }

}

// example of a call
Foo.method1()
```
