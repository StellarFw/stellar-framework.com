---
title: Cluster
type: guide
order: 7
---

## Overview

Stellar may be executed on a single server or as part of a cluster. The aim of the cluster is create a set of servers that share the same state between them in order to respond to a greater number of client requests and to perform more tasks. With this mechanism, you can add and remove nodes from the cluster with no loss of data or duplicate tasks. You can also run multiple instances of Stellar on the same machine using the `stellar startCluster` command.

The names of the cluster instances are sequential, starting with `stellar-worker-1`. The instance name can be obtained from the `api.id` property.

## Cache

Once Stellar uses a Redis backend to retain information of tasks to be executed and cached objects, the cluster takes advantage of that same system to share information across all nodes. Thus, it should be unnecessary to make any changes in the code to be able to deploy the application in a cluster.

> Note: Other clients/servers can access the cache simultaneously. You must be aware of this when you develop actions so that there are no conflicts. You can read more about the [cache here](cache.html).

## RPC

Stellar implements a Remote Procedure Call (RPC), which allows you to run a particular command on all cluster nodes or on a specific node identified by the `connectionId` object. To make use of this feature, use the `api.redis.doCluster(method, arguments, connectionId, callback)` method.  When you specify a callback, it will receive the first response from the cluster (or a timeout error).

### Example

The example bellow causes all nodes print their IDs to the log file:

```javascript
api.redis.doCluster('api.log', [`Hello from the node ${api.id}`])
```

> Note: This mechanism allows you to run any method of the API, including the `stop()` function.

## Redis Pub/Sub

There is also a publish/subscribe mechanism through Redis, which allows communications between the cluster nodes. You can send a broadcast message to other cluster nodes using the `api.redis.publish(payload)` method. The `payload` must contain the following properties:

- **`messageType`**: Name of payload type.
- **`serverId`**: The server ID, given by `api.id`.
- **`serverToken`**: The server token, given by `api.config.general.serverToken`.

### Example

The following example shows how you can subscribe to a particular message type.

```javascript
api.redis.subscriptionHandlers['messageType'] = message => {
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

> Note: The `api.config.general.serverToken` setting authenticates the message in the cluster.
