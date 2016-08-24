---
title: Cluster
type: guide
order: 7
---

## Overview

Stellar may be executed on a single server or as part of a cluster. The aim of the cluster is create a set of servers that share the same state between them in order to respond to a greater number of customer orders, and perform tasks. With this mechanism, you can add and remove nodes from the cluster with no loss of data or duplicate tasks. You can also run multiple instances of Stellar on the same machine using the `stellar startCluster` command.

The name of the cluster instances are sequential, starting in `stellar-worder-1`. The instance name can be obtained by `api.id` property.

## Cache

Once Stellar uses a Redis backend to retain information of tasks to be executed and cached objects, the cluster takes advantage of that same system to share information across all nodes. This makes not necessary any changes in the code to be able to deploy the application in a cluster.

> Note: Other clients/servers can access the cache simultaneously. You must be aware of it when you develop actions to be no conflicts. You can read more about [cache here](cache.html).

## RPC

Stellar implements a Remote Procedure Call (RPC), which allows you to run a particular command on all cluster nodes or in a specific node by the connection object. To make use of this feature you only have to use the `api.redis.doCluster(metodo, argumentos, Id_da_conexao, callback)` method, when you specify a callback, will receive the first response from the cluster (or a timeout error).

### Example

The example bellow causes all nodes print their IDs to the log file:

```javascript
api.redis.doCluster('api.log', [`Hello from the node ${api.id}`])
```

> Note: This mechanism allows you to run any method of the API, including the `stop()` function.

## Redis Pub/Sub

There is also a pub/sub mechanism through Redis, which allows communications between the cluster nodes. YOu can send a broadcast message and receive messages from other cluster nodes using the `api.redis.publish(payload)` method. The `payload` must contain the following properties:

- **`messageType`**: Name of payload type;
- **`serverId`**: Server id, `api.id`;
- **`serverToken`**: `api.config.general.serverToken`

### Example

The following example shows how you can subscribe to a particular message type.

```javascript
api.redis.subscriptionHandlers['messageType'] = menssage => {
  // do something...
}
```

To send a message you use a similar code like the following:

```javascript
// build the payload
let payload = {
  messageType: 'messageType',
  serverId: api.id,
  serverToken: api.config.general.serverToken,
  message: 'Message content!'
}

// publish the message on Redis server
api.redis.publish(payload)
```

> Note: The `api.config.general.serverToken` allows authenticate the message in the cluster.
