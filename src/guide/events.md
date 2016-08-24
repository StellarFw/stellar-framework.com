---
title: Events
type: guide
order: 13
---

## What is?

Stellar has an event system that allows you to subscribe and listening for events in the application. This is useful to manipulate data during the execution or extend features by adding new behaviors to the existing logic. Listeners must be stored in the modules `listeners` folder.

## Generate Listeners

Of course, manually create files for each listener is heavy. Instead, developers can use the command line tool to do this automatically:

```shell
$ stellar generateEvent <eventName> --module=<moduleName>
```

## Define a Listener

The code bellow shows the implementations of a listener, in this example the listener will respond to the `social.newComment` event and will add a new task to the system to process and sending an email every time a comment is made.

```javascript
// File: social/listeners/comments.js

'use strict'

exports.default = [{
  event: 'social.newComment',
  run: (api, params, next) {
    // enqueue a task to send a notification email for the new comment
    api.tasks.enqueue('sendNewCommentEmail', params)
    
    // create a new property called `emailSent` and set it to `true`
    params.emailSent = true

    // next(error <Error>)
    next()
  }
}]
```

## Trigger Events

The code bellow shows how an event can be triggered. In this case the developer wants to fire the `social.newComment` event and give listeners a variable with the new comment data:

```javascript
api.events.fire('social.newComment', newComment, response => {
  // do something with the modified data...
})
```

## Register a Listener Manually

To register a listener manually the developer can use the following API:

```javascript
api.events.listener('blog.newUser', (api, params, next) => {
  // do something...

  // finish the listener execution
  next()
})
```