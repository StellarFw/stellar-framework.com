---
title: Events
type: guide
order: 12
---

## Overview

Stellar has an event system that allows you to subscribe to and listen for events in the application. This is useful to manipulate data during the execution or extend features by adding new behaviors to the existing logic. Listeners must be stored in a module's `listeners` folder.

## Generate Listeners

Instead of manually creating a file for each listener, developers can use the `stellar` command line tool to do this automatically:

```shell
$ stellar makeListener <eventName> --module=<moduleName>
```

## Define a Listener

The code below shows the implementation of a listener.  In this example the listener will respond to the `social.newComment` event and will add a new task to the system to send an email every time a comment is made.

```javascript
// File: modules/social/listeners/comments.js

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

The code below shows how an event can be triggered, the event system uses promises to get away from the callback-hell. In this case the developer wants to fire the `social.newComment` event and give listeners a variable with the new comment data:

```javascript
api.events.fire('social.newComment', newComment)
  .then(response => {
    // do something with the modified data...
  })
```

## Register a Listener Manually

To register a listener manually the developer can use the following API:

```javascript
api.events.listener('blog.newUser', (api, params, next) => {
  // pass a property to the response
  params.someKey = 'someValue'

  // finish the listener execution
  next()
})
```
