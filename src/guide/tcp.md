---
title: TCP
type: guide
order: 15
---

## Overview

You can also interact with Stellar using a persistent connection through a TCP socket. By default is used the port 5000, but this can be changed setting the `api.config.tcp.port` property. Since this is a persistent connection verbs are used to send commands to the server. The list below shows all available verbs:

- **`quit`**: disconnect from the server (the session is destroyed);
- **`paramAdd`**: save a single variable to your connection
  - Example: `addParam query=something`
- **`paramView`**: returns the details of a single param
  - Example: `paramView query`
- **`paramDelete`**: deletes a single a single param
  - Example: `paramDelete query`
- **`paramsView`**: returns a JSON object of all the params set to this connection
- **`paramsDelete`**: deletes all params set to this session
- **`detailsView`**: show you details about your connection, including about the members currently in that room
- **`roomAdd`**: connect to a room
- **`roomLeave <room>`**:  leave the room you are connected to
- **`roomView <room>`**: show you the room you are connected to, and information about the members currently in that room
- **`say <room,> <message>`**: send a message to a room

> Note: the parameters added in previous calls are fixed to the connection, this means that it is necessary to remove the parameters before calling new verbs.

![Telnet TCP](/images/telnet_tcp.png)

One of the main advantages of using a TCP connection is the possibility to call several actions simultaneously. Stellar keep a count of the calls, so you can keep the management of the different calls in progress.

## TLS

The TCP server supports encrypted connections via TLS, if desired. For this you need to make some small settings on the server:

```javascript
'use strict'

exports.default = {
  servers: {
    socket: api => {
      secure: true,
      key: fs.readFileSync('certs/server-key.pem'),
      cert: fs.readFileSync('certs/server-cert.pem')
    }
  }
}
```

The secure connection can be tested using the follow command:

```shell
$ openssl s_client -connect 127.0.0.1:5000
```

Or, you can use another node process:

```javascript
let fs = require('fs')
let tls = require('tls')

let options = {
  key: fs.readFileSync('certs/server-key.pem'),
  cert: fs.readFileSync('certs/server-cert.pem')
}

let socket = tls.connect(5000, options, () => {
  console.log('cliente', socket.authorized ? 'autorizado' : 'não autorizado')
})

socket.setEnconding('utf8')
socket.on('data', data => console.log(data))
```

## JSON

The default way to execute actions on Stellar via a TCP connection is using the verbs available for persistent connections. However, it is possible to use JSON to choose the action to execute and pass a list of parameters. For example, `{"action": "actionName", "params": {"key": "some_value"}}`.
