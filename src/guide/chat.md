---
title: Chat
type: guide
order: 9
---

## Overview

Stellar ships with a chat framework which may be used by all persistent connections (TCP and WebSocket). There are methods to create and manage chat rooms and control the users in those rooms. Chat does not have to represent peer-to-peer communications - it is a metaphor used for many things, including game state in multiplayer games.

Clients themselves interact with rooms via `verbs`. Verbs are short-form commands that will attempt to modify the connection's state, either joining or leaving a room. Clients can be in many rooms ate once. The most relevant chat verbs are:

- `roomAdd`
- `roomLeave`
- `roomView`
- `say`

This feature can be used out-of-the-box without any additional packages, configuration or programming. By default, a room named "defaultRoom" is created when the framework starts. When the WebSocket server is active it generates a client script that can be used in web applications to facilitate calling actions and communicating with the chat rooms.

> Warning: There is no limit on the number of rooms which can be created, but keep in mind that each room stores information in Redis, and each connection requires additional resources as well.

## Methods

These methods can be used within your server. They are not exposed directly to clients, but they can be used within an action or a satellite.

### Emit an Event

The `emit(room, event, data, connection = {})` method allows us to send an event to a specific chat room. All the parameters are required, with the exception of the last one (`connection`). This returns a `Promise` and throw an error when something wrong happens.

```js
await api.chatRoom.emit('players', 'positionUpdate', { id: 123, pos })
```

The `connection` parameter can be used to identifier the message originator.

### Broadcast

The `broadcast(connection, room, message)` method allows you to send a generic message to all members in a room. The connection parameter can be a real connection (a message coming from a client), or a mockConnection. A mockConnection at the very least has the form `{room: 'someRoom'}`. When an ID is not specified the ID will be assigned to 0. As return this method give us a `Promise`.

```js
await api.chatRoom.broadcast({room: 'general'}, 'general', 'Hello!')
```

### List of Rooms

The `list()` allows you to get a list of existing rooms. The following example code lists all rooms in the console (`stdout`):

```js
const rooms = await api.chatRoom.list()

rooms.forEach((room, index) => console.log(`${index} => ${room}`))
```

### Create a Room

To create a room you use the `create(room)` method. The methods returns a `Promise`. The following code shows the creation of a new room named "labs":

```js
await api.chatRoom.create('labs')
```

###  Destroy a Room

Using the `destroy(room)` method, you can remove a room. The method returns a `Promise`; the room is always removed. The following code shows how you can remove a room:

```js
await api.chatRoom.destroy('labs')
```

### Check if the Room Exists

You can use the `exists(room)` method to check if a given room exists in the Stellar instance. The method returns a `Promise`, that resolves with `true` if the room exists, and `false` otherwise.

The following code checks the existence of the chat room named "coffeeTable":

```js
const found = await api.chatRoom.exists('coffeeTable')
```

### Gets the Room State

With the `roomStatus(room)` method you can get room status information. The method returns a `Promise`, as response is given an object containing information about the room: name, number of registered members, and the list of such members.

The code below shows how this information can be obtained and then a possible result:

```js
const status = await api.chatRoom.status('Random')
```

```js
{
  room: 'Random',
  membersCount: 3,
  members: {
    g0m: {id: 'g0m', joinedAt: 1465829955},
    afls: {id: 'afls', joinedAt: 1465829985},
    amg: {id: 'amg', joinedAt: 1465830011}
  }
}
```

### Add a Member

To add a new member to a room, use the `join(connectionId, room)` method. The client connection ID and the name of the room are needed. The method returns a `Promise` that resolves of rejects depending on whether the member was added or not.

```js
const wasAdded = await api.chatRoom.join(connectionId, 'newUsers')
```

> Note: you can add connections from the current server or any other server in the cluster.

### Remove a Member

The `leave(connectionId, room)` method allows you to remove a member from a given room. This requires the member's connection ID and the name of the room. As return this will give us a `Promise`.

```js
const wasRemoved = await api.chatRoom.leave(connectionId, 'heaven')
```

> Note: you can remove connections from the current server or any other server in the cluster.

## Middleware

There are 4 types of middleware you can install for the chat system: `say`, `onSayReceive`, `join`, and `leave`. All documentation about _middleware_ is available in the [middleware section](./middleware.html).

## Chatting to Specific Clients

Every connection object also has a `connection.sendMessage(message)` method which you can call directly from the server.

```js
connectionObj.sendMessage('Welcome to Stellar :)')
```

## Catching the Event

In order to catch an event send by a client you can use the Stellar's [event system](./events.html). When a event is received two events are fired, one with the generic event, and another also with the event, but specific to a room.

For example, if you want to catch the `newItem` event on the room `world1` you must use the `event.world1.newItem`. But if you just want to catch the event, independent of the room you just need to catch the `event.newItem` event.

## Client Functions

The ways it is possible to communicate with the client are described in the sections documenting the types of bidirectional servers, [websocket](websocket.html) and [TCP](tcp.html).
