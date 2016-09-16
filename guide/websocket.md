---
title: WebSocket
type: guide
order: 14
---

## Overview

Stellar uses [Primus](http://primus.io) to work with WebSockets. Primus provides an abstraction layer over a WebSocket engine; it supports `ws`, `engine.io`, and `socket.io`, among others. WebSockets can use HTTP or HTTPS to connect to the server (HTTPS is recommended).

When Stellar starts, a script is generated with some useful functions to make the connection between the client and the server. This script can be obtained by accessing the URL `http(s)://stellar_domain.com/stellar-client`

## Methods

The following methods are provided to the client to interact with the server:

### Open Connection

The `client.connect(callback)` method allows a client to open a connection with the server:

- **`callback(error, detailsView)`**: Callback function:
  - **`error`**: Object with the error that occurred during the call, if any.
  - **`detailsView`**: The same as for the `detailsView` method (see below).

### Call an Action

The `client.action(action, params, callback)` method allows a client to invoke an action:

- **`action`**: Action name to be called, e.g., "auth.signin".
- **`params`**: Object with the action parameters.
- **`callback(response)`**: Callback function:
  - **`response`**: Server response.

> Note: When an open WebSocket connection does not exist, the client will fall back to HTTP.

### Send Messages

The `client.say(room, message, callback)` method allows a client to send message to a chat room:

- **`room`**: Room where the message will be sent.
- **`message`**: Message to be sent.
- **`callback(error)`**: Callback function:
  - **`error`**: Contains the error information, if an error occurred.

> Note: you need use the `roomAdd` method before you can interact with a chat room.

### Details

The `client.detailsView(callback)` method allows you to get details about the client connection.

- **`callback(error, response)`**: Callback function:
  - **`error`**: May contain an instance of `Error`.
  - **`response`**: Contains an object with the connection details.

> Note: the first response of the `detailsView` method is stored to be used in the future.

### Chat Room State

The `client.roomView(room, callback)` method allows you to obtain metadata for the requested chat room.

- **`room`**: Chat room name.
- **`callback(response, error)`**: Callback function.
  - **`response`**: Object with metadata for the requested chat room.
  - **`error`**: Contains an instance of `Error`, if an error occurred.

### Join a Chat Room

The `client.roomAdd(room, callback)` method allows you to join to a chat room:

- **`room`**: Chat room name;
- **`callback(error)`**: Callback function:
  - **`error`**: Can contain an instance of `Error`.

### Leave a Chat Room

The `client.roomLeave(room, callback)` allows you to leave a chat room:

- **`room`**: Chat room name;
- **`callback(error)`**: Callback function:
  - **`error`**: Can contain an instance of `Error`.

### Request a File

The `client.file(file, callback)` method allows you request a static file from the server:

- **`file`**: Path for the file to be requested.
- **`callback(response, error)`**: Callback function.
  - **response**: Object with the requested file.

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

```javascript
client.on('connected', () => { })
```

### Disconnected

The `disconnected` event is triggered when the client disconnects from the server.

```javascript
client.on('disconnected', () => { })
```

### Error

The `error` event is triggered when an error occurs during a verb execution.

```javascript
client.on('error', error => { })
```

### Reconnect

The `reconnect` event occurs when the connection between the server and the client is temporarily interrupted.

```javascript
client.on('reconnect', () => { })
```

> Note: the connection details can be changed when a reconnect occurs.

### Reconnecting

The `reconnecting` event occurs when the client tries to reconnect with the server.

```javascript
client.on('reconnecting', () => { })
```

### Message

The `message` event occurs when the client receives a new message.

```javascript
client.on('message', message => { })
```

> Warning: this event occurs every time the client receives a new message - this is a very noisy event.

### Alert

The `alert` event occurs when the client receives a new message from the server with the `alert` context.

```javascript
client.on('alert', message => { })
```

### API

The `api` event occurs when the client receives a new message with an unknown context.

```javascript
client.on('api', message => { })
```

### Welcome

The `welcome` event occurs when the server sends a welcome message to the new-connected client.

```javascript
client.on('welcome', message => { })
```

### Say

Finally, the `say` event occurs when the client receives a new message from another client in the same room.

```javascript
client.on('say', message => { })
```
> Note: the `message.room` property allows you to get the message origin.
