---
title: Actions
type: guide
order: 3
---

## What is an Action?

Actions are the building blocks of Stellar, the basic units of the framework. A Stellar project is a repository containing one or more actions. An action can be invoked directly by a client or internally by other actions. Actions can receive a set of inputs and return a set of outputs. Actions can be marked private so that they can only be called by other actions and not by the client. Actions can also be overridden by other modules, unless they are marked as protected.

Developers can create their own actions by creating a new file in a module's `actions` folder, or they can use the `stellar` command-line tool to generate the file and its contents automatically:

```bash
stellar make action <name_of_action>
```

Optionally, you can use the `--module` option to define the module where the action must be created, by default the "private" module will be used.

The actions are loaded into the Stellar Engine when it starts. Actions can be invoked by other actions (including those in other modules).

```js
exports.randomNumber = {
  name: 'randomNumber',
  description: 'Generate a random number',
  outputExample: {
    number: 0.40420848364010453
  },

  run (api, action, next) {
    // generate a random number
    var number = Math.random()

    // save the generated number in an output parameter
    action.response.number = number

    // returns a formatted string
    action.response.formattedNumber = `Your random number is ${number}`

    // finish the action execution
    next()
  }
}
```

An action is composed of two mandatory properties: `name` identifies the action, and `run` is a function which implements the action logic. Actions can contain other information such as a description, input value restrictions, middleware, and an output example. Stellar can use this metadata to generate fully automatic documentation for all the actions in a project; this is especially useful for large projects with big development teams.

In the code snippet above you can see the structure of an action which generates a random number.

Actions are asynchronous and receive a reference to an `api` object (providing access to shared functions of the Engine), an `action` object, and a `next` callback function. To complete the execution of an action, simply call the `next()` function. An instance of `Error` can be passed as an argument to the `next` function; in this case, an error message will be sent to the client. In alternative, you can return an `Promise` and depending of the result will be sent a response to the client (an error in case of rejection).

Actions can be invoked by other actions; this allows an action's code to be reused for different usage scenarios.

## Properties

All properties that can appear in actions are listed below:

- **`name`**: A unique action identifier. It is recommended to use a namespace to eliminate the possibility of collision; for example, `auth::login`.
- **`description`**: Describes the action.  This information is used in automatic documentation.
- **`inputs`**: Enumerates the action's input parameters. You can also apply restrictions on input values.
- **`middleware`**: Indicates the middleware to be applied before and after the execution of the action. Global middleware is automatically applied.
- **`group`**: Group which this action is part.
- **`outputExample`**: Contains an example of an action response. This example will be used in automatic documentation.
- **`blockedConnectionTypes`**: Blocks certain types of connections.
- **`logLevel`**: Defines how the action should be logged.
- **`protected`**: When `true`, prevents the action from being overridden by a higher priority module.
- **`private`**: When `true`, the action can only be called internally.
- **`toDocument`**: By default, this property is set to `true`; otherwise documentation will not be generated for this action.
- **`run`**: The function which implements the logic of the action. It receives three input parameters `(api, action, next)`.

> Note: Some of the metadata, as in the case of `outputExample` and `description`, are used only to generate the automatic documentation.

## Versions

Stellar supports multiple versions of the same action. This allows you to create a new action with the same name as an existing action, but with improved features. This is useful when there are many existing client applications that use the API; you can update your actions without fear of breaking older versions and clients can individually update to the new API without service interruption in other clients.

Actions can optionally contain a `version` property. When a client makes a request, it can set the `apiversion` parameter to ask for a specific version of the action.

> Note: When no `apiVersion` parameter is defined, Stellar will respond with the latest version of the action.

##  Input Declaration

In the action declaration you can specify the input fields using the `inputs` property; this will apply restrictions to the input values. These restrictions can be validators already defined in the system, a regular expression, or a function which returns a boolean (where `true` indicates that the input value is valid). Finally, you can also convert input values to a specific data type (integer, float, and string) or use a function to format the value.

The list below shows all available properties to use on the input fields:

- **`required`**: indicates whether the parameter is required.
- **`format`**: allows you to format the parameter to a specific data type or string format.
- **`default`**: default value if the parameter is not present in the set of inputs provided by the client.
- **`validator`**: validates the parameter using one or more constraints.

> Note: you can learn more about [Validators here](validation.html).

### Using a default value

If your parameter is optional you may want use a default value for it. The follow snippet shows how you can do that, the first input field uses a static declaration and the seconds one uses a function:

```js
{
  name: 'getCommissionsByRange',

  inputs: {
    start: {
      default: new Date(2016, 1, 1)
    },
    end: {
      default: api => {
        const today = new Date()
        return new Date(2016, today.getMonth(), 30)
      }
    }
  },

  run (api, action) {
    // (...)
  }
}
```

When you use a function to define the default parameter value you get access to the API object, as you can see on the example above.

## Parameter Conversions

To remove the need for developers to manually convert input parameters to their required type, Stellar provides a way to convert them automatically before performing the action. The `format` property can be a string with the values (`string`, `integer` or `float`) or a function (`(api, value)`).

### Example

The example below shows the conversion of a parameter to the integer type:

```js
exports.giveAge = {
  name: 'giveAge',
  description: 'Give the name and age based on the year of birth',

  inputs: {
    name: {
      required: true
    },
    birthYear: {
      required: true,
      format: 'integer'
    }
  },

  run (api, action, next) {
    // calculate the person's age (action.params.birthYear is already a number)
    let age = new Date().getFullYear() - action.params.birthYear

    // return a phrase with the name and age
    action.response.result = `${action.params.name} is aged ${age} years`

    // finish the action execution
    next()
  }
}
```

## Action Parameter

The second parameter of the `run` function is the `action` object. This object captures the state of the connection at the time the action was started. Middleware preprocessors have already fired, and input formatting and validation has already occurred. The image below shows some of the properties of the `action` object:

<div style="max-width: 434px; margin-left: auto; margin-right: auto;">
  ![Properties of the Action Object](/images/action_obj.png)
</div>

The goal of most actions is to perform a series of operations and change the `action.response` property, which will later be sent to the client. You can modify the connection properties by accessing `action.connection`, and change, for example, the HTTP headers. If you do not want the Engine to send a response to the client (for example, it has already sent a file), set the `action.toRender` property to `false`.

## Internal Calls

In order to improve code reuse when actions partially share the same logic, Stellar implements a mechanism to make internal calls to actions. This means that you can extract part of the logic of one (or more) actions into simpler actions, which may also be used by other actions. Thus, from the composition of simple actions you can create more complex actions without making the code difficult to maintain.

To call an action internally, use the `api.actions.call(actionName, params, callback)` method:

- **`actionName`**: Action name to call;
- **`params`**: Parameters to be passed to the action.
- **`callback(error, response)`**: Callback function.
  - **`error`**: `Error` returned by the action call.
  - **`response`**: Object with the action response.

### Private Actions

Sometimes you might create actions that you do not want to be called by clients, because they are for internal use only. They don't provide useful operations to the clients by themselves, or they are critical functions which should not have public exposure. For that Stellar allows you to define an action as private, so it can only be called internally. To make an action private, simply include the `private: true` property in the target action.

### Example

The example below shows an internal call to an action called `sumANumber`; after execution, the result is printed out to the console. The complete example can be found [here](https://github.com/StellarFw/stellar/blob/dev/example/modules/test/actions/internalCalls.js).

```js
api.actions.call('sumANumber', { a: 3, b: 3 }, (error, response) => {
  console.log(`Result => ${response.formatted}`)
})
```

In alternative, you can use a Promise like style, as you can see here:

```js
api.actions.call('sumANumber', { a: 3, b: 3 }).then(response => {
  console.log(`Result => ${response.formatted}`)
})
```

> Note: you can also call actions from tasks or listeners.

## Automatic Documentation

Stellar can generate documentation fully automatically. The required information is extracted from the actions' properties. To avoid generating documentation for an action, you must add `toDocument: false` to the action in question; if you want disable documentation for all actions you can set the `api.config.general.generateDocumentation` setting to `false`. To access the documentation just visit the URL `docs/index.html` on the HTTP server.

![Automatic Documentation](/images/auto_docs.png)

The image above shows an example of Stellar's automatically generated documentation. In the sidebar are all existing actions in the project, including private actions. In the section on the right you can see details of the selected action such as name, description, input fields with their restrictions, and an output example. When actions have multiple versions, all of the versions are displayed.

## Middleware

You can apply middleware to your actions (before and after the action is performed). Middleware can be global (applied to all actions) or defined specifically for each action using the `middleware` property, providing the name of each piece of middleware to apply to that action.

You can learn more about [middleware here](middleware.html).

### Example

The following example shows the declaration of an action that contains two middleware components:

```js
exports.getAllAccounts = {
  name: 'getAllAccounts',
  description: 'Get all registered accounts',

  middleware: ['auth', 'superResponse'],

  run (api, action, next) {
    // perform some operation...

    // finish action execution
    next()
  }
}
```

## Using Promises

You can use Promises to finish actions instead using callbacks. This allows you to write even more clean code, but you can continue using the old callback way. The Promises only are useful in some specific use cases, like after read data from a model. The follow example shows one of that cases:

```js
exports.getAllPosts = {
  name: 'getAllPosts',

  run (api, action) {
    return api.models.get('post')
      .find({})
      .then(posts => { action.response.posts = posts })
  }
}
```

## Modification System

Ok! Now we can divide our application into small components, named actions, that can be connected to others in order to create more complex ones. Besides that we can also group them into modules to increase the reusability of the features, so we can easily import them to other projects, saving time and extra lines of code. But sometimes this isn't enough.

Imagine that you are using the ["identify"](https://github.com/stellarFw/identify) module, that is responsible to add all the basic features to manage your's applications authentication features. But, by default, this module expose all the actions to public, even the ones that allow create and get all the registered users. So, you need to protect the access to that actions. But who will you do that? Editing the code manually? No!

Stellar comes withe a powerful modification mechanism that allows you define groups in order to apply modifications to your actions. The follow example shows a group, named "protections", that makes the `auth.getUsers`, `auth.getUser`, `auth.editUser`, and `auth.removeUser` all private.

```js
// This receives the API reference in case of you need it
module.exports = api => {
  // The function must return an hash, which the keys correspond to the
  // modification section (in this case actions)
  return {
    // The keys of this hash correspond to the groups names.
    //
    // To define the actions that made part of the group, you can define it
    // directly on the action or you can specify it here using the `actions`
    // and/or `modules` keys, but you'll see it in a second.
    actions: {
      // this is the name of our group, in this case "protections"
      protections: {
        // Here we define all the actions that we want to be part of this group
        actions: [ 'auth.getUsers', 'auth.getUser', 'auth.editUser', 'auth.removeUser' ],

        // we can also add all the action of a module to a group, for that we
        // define the `module` array

        // We can also define modules (module slugs) if our intention is to
        // include all actions that are part of a module
        // modules: [ 'entrust' ],

        // the `metadata` is an hash that contains the modifications to be
        // applied to each action that are part of this group
        //
        // In each key we can prefix it with a `+`, that means "is to append to",
        // we can use '-', that means "remove", or when you don't use nothing of
        // this an replace operation will be performed.
        //
        // The value can also be an function, it will receive the action object,
        // and the correspondent value that we are changing. The return will
        // replace the property under work.
        metadata: {
          // in this case we only want make all the action private
          private: true
        }
      }
    }
  }
}
```

As you can see, we provide a set os mechanism and technics that allows you to apply changes on the original actions, from other modules, this order to maximize the reusability of your code.
