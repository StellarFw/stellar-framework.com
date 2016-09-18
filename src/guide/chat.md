---
title: Chat
type: guide
order: 10
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

### Broadcast

The `api.chatRoom.broadcast(connection, room, message, callback)` method allows you to send a message to all members in a room. The connection parameter can be a real connection (a message coming from a client), or a mockConnection. A mockConnection at the very least has the form `{room: 'someRoom'}`. When an ID is not specified the ID will be assigned to 0.

```javascript
api.chatRoom.broadcast({room: 'general'}, 'general', 'Hello!', error => {
  // do something after sending the message!
})
```

### List of Rooms

The `api.chatRoom.list(callback)` allows you to get a list of existing rooms. The following example code lists all rooms in the console (`stdout`):

```javascript
api.chatRoom.list((error, rooms) => {
  for (let k in rooms) { console.log(`${k} => ${rooms[k]}`) }
})
```

### Create a Room

To create a room you use the `api.chatRoom.add(room, callback)` method. The callback function receives a parameter that has a value of `0` when the room already exists and `1` if it has just been created. The following code shows the creation of a new room named "labs":

```javascript
api.chatRoom.add('labs', res => {
  if (res === 0) {
    // the room already exists!
    return
  }

  // the room has been created!
})
```

###  Remove a Room

Using the `api.chatRoom.destroy(room, callback)` method, you can remove a room. The callback function does not receive any parameters; the room is always removed. The following code shows how you can remove a room:

```javascript
api.chatRoom.destroy('labs', () => {
  // room removed!
})
```

### Check if the Room Exists

You can use the `api.chatRoom.exists(room, callback)` method to check if the room exists in the Stellar instance. The `callback(error, found)` receives two parameters:

- **`error`**: Assumes the `null` value if there are no problems.
- **`found`**: `true` if the room exists, `false` otherwise.

The following code checks the existence of the chat room named "coffeeTable":

```javascript
api.chatRoom.exists('coffeeTable', (error, found) => {
  if (!found) {
    // the room does not exist!
    return
  }

  // the room exists!
})
```

### Gets the Room State

With the `api.chatRoom.roomStatus(room, callback)` method you can get room status information. The `callback(error, state)` function takes two parameters:

- **`error`**: `null` if no error occurs during the method call.
- **`state`**: An object containing information about the room: name, number of registered members, and the list of such members.

The code below shows how this information can be obtained and then a possible result:

```javascript
api.chatRoom.roomStatus('Random', (error, status) => {
  // do something with the room information!
})
```

```javascript
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

To add a new member, use the `api.chatRoom.addMember(connectionId, room, callback)` method.  The client connection ID and the name of the room are needed. The `callback(error, wasAdded)` function takes two parameters:

- **`error`**: `null` if no error occurs during the call.
- **`wasAdded`**: Can be `true` or `false` depending on whether the member was added or not.

```javascript
api.chatRoom.addMember(connectionId, 'newUsers', (error, wasAdded) => {
  if (!wasAdded) {
    // could not add the new member!
    return
  }

  // client added as a new member!
})
```

> Note: you can add connections from the current server or any other server in the cluster.

### Remove a Member

The `api.chatRoom.removeMember(connectionId, room, callback)` method allows you to remove a member of a given room. This requires the member's connection ID and the name of the room. The `callback(error wasRemoved)` function takes two parameters:

- **`error`**: `null` if no error occurs during the operation.
- **`wasRemoved`**: `true` if the member has been removed, `false` otherwise.

```javascript
api.chatRoom.removeMember(connectionId, 'heaven', (error, wasRemoved) => {
  if (!wasRemoved) {
    // the member has not been removed!
  }

  // the member was removed from the room!
})
```

> Note: you can remove connections from the current server or any other server in the cluster.

## Middleware

There are 4 types of middleware you can install for the chat system: `say`, `onSayReceive`, `join`, and `leave`. All documentation about _middleware_ is available in the [middleware section](./middleware.html).

## Chatting to Specific Clients

Every connection object also has a `connection.sendMessage(message)` method which you can call directly from the server.

```javascript
connectionObj.sendMessage('Welcome to Stellar :)')
```

## Client Functions

The ways it is possible to communicate with the client are described in the sections documenting the types of bidirectional servers, [websocket](websocket.html) and [TCP](tcp.html).
