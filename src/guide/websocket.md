---
title: WebSocket
type: guide
order: 13
---

## Overview

Stellar uses [Primus](http://primus.io) to work with WebSockets. Primus provides an abstraction layer over a WebSocket engine; it supports `ws`, `engine.io`, and `socket.io`, among others. WebSockets can use HTTP or HTTPS to connect to the server (HTTPS is recommended).

When Stellar starts, a script is generated with some useful functions to make the connection between the client and the server. This script can be obtained by accessing the URL `http(s)://stellar_domain.com/stellar-client`

> Note: The newest versions of Stellar uses the new [Fetch API](https://developer.mozilla.org/en/docs/Web/API/Fetch_API) to make HTTP requests to the server. This API isn't supported by some old browsers, so in order to add support for then, you need to use a [Polyfill](https://github.com/github/fetch).

## Methods

The generated client script contains a set of methods to start a real-time communication with the server, make calls to actions, send messages to chat rooms, and lots of others useful features. All those methods uses [Promises](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) that means you can get rid of the callback hell.

> Note: in older browsers you will need load a [polyfill](https://github.com/taylorhakes/promise-polyfill) in order to this work properly.

The following methods are provided to the client interact with the server:

### Open Connection

The `client.connect()` method allows a client to open a connection with the server.

- Return a Promise:
  - **`reject`**: Object with the error that occurred during the call, if any.
  - **`resolve`**: The same as for the `detailsView` method (see below).

### Call an Action

The `client.action(action, params = {})` method allows a client to invoke an action:

- **`action`**: Action name to be called, e.g., "auth.signin".
- **`params`**: Object with the action parameters.
- Returns a Promise:
  - **`reject`**: Server response, when an error was occurred.
  - **`resolve`**: Server response.

> Note: When an open WebSocket connection does not exist, the client will fall back to HTTP.

### Send Messages

The `client.say(room, message)` method allows a client to send message to a chat room:

- **`room`**: Room where the message will be sent.
- **`message`**: Message to be sent.
- Returns a Promise:
  - **`reject`**: Contains the error information, if an error occurred.

> Note: you need use the `roomAdd` method before you can interact with a chat room.

### Details

The `client.detailsView()` method allows you to get details about the client connection.

- Returns a Promise:
  - **`reject`**: May contain an instance of `Error`.
  - **`resolve`**: Contains an object with the connection details.

> Note: the first response of the `detailsView` method is stored to be used in the future.

### Chat Room State

The `client.roomView(room)` method allows you to obtain metadata for the requested chat room.

- **`room`**: Chat room name.
- Returns a Promise:
  - **`resolve`**: Object with metadata for the requested chat room.
  - **`reject`**: Contains an instance of `Error`, if an error occurred.

### Join a Chat Room

The `client.roomAdd(room)` method allows you to join to a chat room:

- **`room`**: Chat room name;
- Returns a Promise:
  - **`reject`**: Can contain an instance of `Error`.

### Leave a Chat Room

The `client.roomLeave(room)` allows you to leave a chat room:

- **`room`**: Chat room name;
- Returns a Promise:
  - **`reject`**: Can contain an instance of `Error`.

### Request a File

The `client.file(file)` method allows you request a static file from the server:

- **`file`**: Path for the file to be requested.
- Returns a Promise:
  - **resolve**: Object with the requested file.

The response object has the following structure:

```json
{
  "content": "File Content...",
  "context": "response",
  "error": null,
  "length" 20,
  "messageCount" : 3,
  "mime": "text/txt"
}
```

### Disconnect

The `client.disconnect()` method allows you to disconnect the client from the server.

## Events

The following list shows the events which are available to the client.

### Connected

The `connected` event is triggered when the client connects to the server.

```js
client.on('connected', () => { })
```

### Disconnected

The `disconnected` event is triggered when the client disconnects from the server.

```js
client.on('disconnected', () => { })
```

### Error

The `error` event is triggered when an error occurs during a verb execution.

```js
client.on('error', error => { })
```

### Reconnect

The `reconnect` event occurs when the connection between the server and the client is temporarily interrupted.

```js
client.on('reconnect', () => { })
```

> Note: the connection details can be changed when a reconnect occurs.

### Reconnecting

The `reconnecting` event occurs when the client tries to reconnect with the server.

```js
client.on('reconnecting', () => { })
```

### Message

The `message` event occurs when the client receives a new message.

```js
client.on('message', message => { })
```

> Warning: this event occurs every time the client receives a new message - this is a very noisy event.

### Alert

The `alert` event occurs when the client receives a new message from the server with the `alert` context.

```js
client.on('alert', message => { })
```

### API

The `api` event occurs when the client receives a new message with an unknown context.

```js
client.on('api', message => { })
```

### Welcome

The `welcome` event occurs when the server sends a welcome message to the new-connected client.

```js
client.on('welcome', message => { })
```

### Say

Finally, the `say` event occurs when the client receives a new message from another client in the same room.

```js
client.on('say', message => { })
```
> Note: the `message.room` property allows you to get the message origin.

## Interceptors

Interceptors can be used for pre- and post-processing a request. This is particularly useful for authentication and prevent unnecessary requests to the server, for some specific case. The follow examples shows different ways of using interceptors.

This example shows how to append or modify request's parameters:

```js
client.interceptors.push((params, next) => {
  params.token = LocalStorage.getItem('token')

  next()
})
```

Here we prevent the request to be send to the server returning an object as request's response:

```js
client.interceptors.push((params, next) => {
  next({ someKey: 'someValue' })
})
```

In this next case we also prevent the request to happen but this time we return an error:

```js
client.interceptors.push((params, next) => {
  next(null, { message: 'Bad news! An error was occurred.' })
})
```

Finally, we can also change the server response passing a function to the `next()`:

```js
client.interceptors.push((params, next) => {
  next(response => {
    response.additionalField = 'Awesome call...'
  })
})
```
