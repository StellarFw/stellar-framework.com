---
title: Middleware
type: guide
order: 5
---

## Overview

Developers can create middleware that can be applied before and after the execution of an action. There are two types of middleware: global middleware, which is applied to all actions, and individual middleware, which is applied individually to each action using the `middleware` property. Each middleware component has a priority that will set the execution order of the middleware.  Middleware can also be classified as _Action Middleware_, _Connection Middleware_, or _Chat Middleware_.  Each is distinct from the other and operates in different parts of the connection lifecycle.

### Lifecycle

![Request Flow](/images/middleware_lifecycle.png)

As can be seen in the image above, there are a number of different places where you can run middleware. The following list shows the different middleware available on Stellar:

- When a client connects
  - connection middleware, `create`
- When a client makes a request to an action
  - action middleware, `preProcessor`
  - action middleware, `postProcessor`
- When a client joins to a chat room
  - chat middleware, `join`
- When a client sends a message to a chat room
  - chat middleware, `say`
  - chat middleware, `onSayReceive`
- When a client makes a request to disconnect (_quit_)
  - chat middleware, `leave`
  - connection middleware, `destroy`

## Types of Middleware

### Action Middleware

Stellar offers hooks to execute code before and after specified actions; this is the appropriate place to add logic related to authentication or to validate the state of a given resource.

### Connection Middleware

You can create middleware to react to the creation and destruction of all connections. Unlike action middleware, they are asynchronous and do not block the request until they finish executing.

Keep in mind that some connections persist (WebSocket, TCP) and some only exist for the duration of a single request (web). You will likely want to inspect `connection.type` in this middleware. If you do not provide a priority, the default from `api.config.general.defaultProcessorPriority` will be used.

### Chat Middleware

The last type of middleware is used to act when a connection joins, leaves, or communicates within a chat room. We have 4 types of middleware for each step: `say`, `onSayReceive`, `join` and `leave`.

Priority is optional in all cases, but can be used to order your middleware. If an error is returned by any of these methods, it will be returned to the user, and the action/message will not be sent.
