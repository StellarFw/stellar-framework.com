---
title: Middleware
type: guide
order: 5
---

## Overview

Developers can create middlware that can be applied before and after the execution of an action. There are two types of middleware, global, that are applied to all actions and individual that are applied individually to each action using the `action.middleware` property. Each middleware has a priority that will set the execution order of the middleware. There are three types of middleware for actions, connections and chat. Each is distinct from the other and operate in different parts of the customer's lifecycle.

### Lifecycle

![Request Flow](/images/middleware_lifecycle.png)

As can be seen in the image above, there are different places where you can run an middleware. The following list shows the different middleware available on Stellar:

- When a client connect
  - connection middleware, `create`
- A client makes a request to an action
  - action middleware, `preProcessor`
  - action middleware, `postProcessor`
- A client joins to a chat room
  - _Middleware_ de _chat_, `join`
- A client sends a message to a chat room
  - action middleware, `say`
  - action middleware, `onSayReceive`
- A client make a request to disconnect (_quit_)
  - action middleware, `leave`
  - connection middleware, `destroy`

## Types of Middleware

### Action Middleware

Stellar offers hooks to execute code before and after some actions, this is the appropriate place to add logic related to authentication or validate the state of a given resource.

### Connection Middleware

You can create middleware to react to the creation and destruction of all connections. Unlike action middleware, they do not block the request until the end of the run, are asynchronous.

Keep in mind that some connections persist (WebSocket, TCP) and some only exist for the duration of a single request (web). You will likely want to inspect `connection.type` in this middleware. Again, if you not provide a priority, the default from `api.config.general.defaultProcessorPriority` will be used.

### Chat Middleware

The last type of middleware is used to act when a connection joins, leaves, or communicate within a chat room. We have 4 types of middleware for each step: `say`, `onSayReceive`, `join` and `leave`.

Priority is optional in all cases, but can be used to order you middleware. If an error is returned in any of these methods, it will be returned to the user, and the action/verb/message will not be sent.
