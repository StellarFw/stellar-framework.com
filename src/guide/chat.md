---
title: Chat
type: guide
order: 9
---

## Overview

Stellar ships with a chat framework which may be used by all persistent connections (TCP and WebSocket). There are methods to create and manage chat rooms and control the users in those rooms. Chat does not have to be peer-to-peer communications, and is a metaphor used for many things, including game state in multiplayer games.

Clients themselves interact with rooms via `verbs`. Verbs are short-form commands that will attempt to modify the connection's state, either joining or leaving a room. Clients can be in many rooms ate once. The must relevant chat verbs are:

- `roomAdd`
- `roomLeave`
- `roomView`
- `say`

This feature can be used out-of-the-box without any installation of additional packages, configurations or programming. By default, a room named "defaultRoom" is created on the framework starts. When WebSocket server is active it generates a client script that can be used in web applications to facilitate the call to actions and communications with the chat rooms.

> Warning: There is no limit on the number of rooms which can be created, but keep in mind that each room stores informations in Redis, and there load created for each connection.

## Methods

These methods are to be used within your server (perhaps an action or satellite). They are not exposed directly to clients, but they can be within an action.

### Broadcast

The `api.chatRoom.broadcast(connection, room, message, callback)` method allows send a message to all members in a room. The connection parameter can be a real connection (a message coming from a client), or a mockConnection. A mockConnection at the very least has the form `{room: 'someRoom'}`. When an id is not specified the id will be assigned to 0.

```javascript
api.chatRoom.broadcast({room: 'general'}, 'general', 'Olá!', error => {
  // do something after send the message!
})
```

### List of Rooms

The `api.chatRoom.list(callback)` allows get a list of existing rooms. The follow example code list all room in the console (`stdout`):

```javascript
api.chatRoom.list((error, rooms) => {
  for (let k in rooms) { console.log(`${k} => ${rooms[k]}`) }
})
```

### Create a Room

To create a room you use the `api.chatRoom.add(room, callback)` method. The callback function receives a parameter that value of `0` when the room already exists and `1` if it has been created. The following code shows the creation oh a new room named "labs":

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

Using the `api.chatRoom.destroy(room, callback)` method you can remove a room. The callback function do not receives any parameter, the room is always removed. The follow code shows who you can remove a room:

```javascript
api.chatRoom.destroy('labs', () => {
  // room removed!
})
```

### Check if the Room Exists

You can use the `api.chatRoom.exists(room, callback)` method to check if the room exists in the Stellar instance. The `callback(error, found)` receives two parameters:

- **`error`**: assumes the `null` value in case of any problems not occurs;
- **`found`**: `true` if the room has been removed, `false` otherwise.

The follow code checks the existence of the chat room named "coffeTable":

```javascript
api.chatRoom.exists('coffeTable', (error, found) => {
  if (!found) {
    // the room not exists!
    return
  }

  // the room exists!
})
```

### Gets the Room State

Trough `api.chatRoom.roomStatus(room, callback)` method you can get room status information. The `callback(error, state)` function, takes two parameters:

- **`error`**: `null` if no error occurs during the method call;
- **`state`**: is a hash containing information about the room: name, number of registered members, and the list of such members.

The code below shows how this information can be obtained and then a possible answer:

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

To add a new member uses the `api.chatRoom.addMember(connectionId, room, callback)` method, the client connection ID and the name of the room where you want to add the new member is needed. The `callback(error, wasAdded)` function takes two parameters:

- **`error`**: `null` if no error occurs during the call;
- **`wasAdded`**: can assume the value of true or false depending on whether the member was added or not.

```javascript
api.chatRoom.addMember(idDaConexao, 'newUsers', (error, wasAdded) => {
  if (!wasAdded) {
    // could not add the new member!
    return
  }

  // cliente adicionado como novo membro!
})
```

> Note: you can add connections from this or any other server in the cluster.

### Remove a Member

The `api.chatRoom.removeMember(connectionId, room, callback)` method allows remove one member of a given room. This required the member's connection ID to be removed from the room where you want to remove. The `callback(error wasRemoved)` function takes two parameter:

- **`error`**: `null` if no error occurs during operation;
- **`wasRemoved`**: `true` if the member has been removed, `false` otherwise.

```javascript
api.chatRoom.removeMember(idDaConexao, 'heaven', (error, wasRemoved) => {
  if (!wasRemoved) {
    // the member has not been removed!
  }

  // the member was removed from room!
})
```

> Note: you can remove connections from this or any other server in the cluster.

## Middleware

There are 4 types of middleware you can install for the chat system: `say`, `onSayReceive`, `join`, and `leave`. All documentation about _middlewares_ are available in the created [section](./middleware.html) for the effect.

## Chatting to Specific Clients

Every connection object also has a `connection.sendMessage(message)` methods which you can call directly from the server.

```javascript
connectionObj.sendMessage('Welcome to Stellar :)')
```

## Client Functions

The way it is possible to communicate through the client is described in sub-sections of each kind of bidirectional servers, [websocket](websocket.html) and [TCP](tcp.html).
