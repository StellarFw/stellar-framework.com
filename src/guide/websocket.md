---
title: WebSocket
type: guide
order: 14
---

## Overview

Stellar uses the [Primus](http://primus.io) to work with WebSockets. Primus creates an abstraction layer over the WebSocket engine, it supports: `ws`, `engine.io`, `socket.io`, among others. The WebSocket is connected to the web server, either HTTP or HTTPS.

When Stellar starts, a script is generated with some useful functions to make the connection between the client and the server. This script can be obtained by calling the URL: `http(s)://stellar_domain.com/stellar-client`

## Methods

Bellow are exposed all methods provided by the client so it can interact with the server:

### Open Connection

The `client.connect(callback)` method allows you open a connection with the server:

- **`callback(error, detailsView)`**: callback function:
  - **`error`**: object with the occurred error during the call, if exists;
  - **`detailsView`**: the same as the `detailsView` method.

### Call an Action

The `client.action(action, params, callback)` method allows call an action:

- **`action`**: action name to be called, for example: "auth.signin";
- **`params`**: object with the action parameters;
- **`callback(response)`**: callback function:
  - **`response`**: server response.

> Note: When does not exists an open connection through a WebSocket, the client will fallback to HTTP.

### Send Messages

The `client.say(room, message, callback)` method allows you to send message to a chat room:

- **`room`**: room for the message will be sent;
- **`message`**: message to be sent;
- **`callback(error)`**: callback function:
  - **`error`**: contains the error information, if that is the case.

> Note: you need use the `roomAdd` method before you can interact with a chat room.

### Details

The `client.detailsView(callback)` method allows you get details about the client connection.

- **`callback(error, response)`**: callback function:
  - **`error`**: may contain an instance of `Error`
  - **`response`**: contains an object with the connection details.

> Note: the first answer of the `detailsView` are stored to be used on the future.

### Chat Room State

The `client.roomView(room, callback)` method allows you to obtain metadata from the request chat room.

- **`room`**: chat room name;
- **`callback(response, error)`**: callback function:
  - **`response`**: Object with metadata from the requested chat room;
  - **`error`**: contains an instance of `Error`, if is that the case.

### Joining a Room

The `client.roomAdd(room, callback)` method allows you joining to a chat room:

- **`room`**: chat room name;
- **`callback(error)`**: callback function:
  - **`error`**: can contains a instance of `Error`.

### Leave a Chat Romm

The `client.roomLeave(room, callback)` allows you to leave a chat room:

- **`room`**: chat room name;
- **`callback(error)`**: callback function:
  - **`error`**: an instance of `Error`, if is that the case.

### Request a File

The `client.file(file, callback)` method allows you request a static file form to the server:

- **`file`**: path for the file to be requested;
- **`callback(response, error)`**: callback function:
  - **response**: object with the requested file.

The answer looks like the follow structure:

```json
{
  "content": "File Content...",
  "context": "response",
  "error": null,
  "lenght" 20,
  "messageCount" : 3,
  "mime": "text/txt"
}
```

### Disconnect

The `client.disconnect()` method allows you disconnect client from the server.

## Events

The follow list shows the available events by the client.

### Connected

The `connected` event is triggered when the client connect with the server.

```javascript
client.on('connected', () => { })
```

### Disconnected

The `disconnected` event is triggered when the client disconnect from the server.

```javascript
client.on('disconnected', () => { })
```

### Error

The `error` event is triggered when the an error occurs during a verb execution.

```javascript
client.on('error', error => { })
```

### Reconnect

The `reconnect` event occurs when the connection between the server and the client are temporarily interrupted.

```javascript
client.on('reconnect', () => { })
```

> Note: the connection details can be changed.

### Reconnecting

The `reconnecting` event occurs when the client try reconnect with the server.

```javascript
client.on('reconnecting', () => { })
```

### Message

The `message` event occurs when the client receives a new message.

```javascript
client.on('message', message => { })
```

> Warning: this event occurs every time the client receive a new message, this is a very noisy event.

### Alert

The `alert` event occurs when the client receives a new message from the server with the `alert` context.

```javascript
client.on('alert', message => { })
```

### API

The `api` event occurs when the client receives a new message with a unknown context.

```javascript
client.on('api', message => { })
```

### Welcome

The `welcome` event occurs when the server send a welcome message to the new-connected client.

```javascript
client.on('welcome', message => { })
```

### Say

Finally, the `say` event occurs when the client receives a new message from the other client in the same room.

```javascript
client.on('say', message => { })
```
> Note: the `message.room` property allows get the message origin.
