---
title: TCP
type: guide
order: 14
---

## Overview

You can also interact with Stellar using a persistent connection through a TCP socket. By default port 5000 is used, but this can be changed by setting the `api.config.tcp.port` property. Since this is a persistent connection verbs are used to send commands to the server. The list below shows all available verbs:

- **`quit`**: disconnects from the server (the session is destroyed)
- **`paramAdd`**: saves a single variable to your connection
  - Example: `paramAdd query=something`
- **`paramView`**: returns the details of a single param
  - Example: `paramView query`
- **`paramDelete`**: deletes a single param
  - Example: `paramDelete query`
- **`paramsView`**: returns a JSON object of all the params set in this connection
- **`paramsDelete`**: deletes all params set in this session
- **`detailsView`**: shows you details about your connection, including about the members currently in the room
- **`roomAdd`**: connects to a room
- **`roomLeave <room>`**:  leaves the room you are connected to
- **`roomView <room>`**: shows you the room you are connected to, and information about the members currently in that room
- **`say <room,> <message>`**: sends a message to a room

> Note: the parameters added in previous calls are fixed to the connection; this means that it is necessary to remove the parameters before calling new verbs.

![Telnet TCP](/images/telnet_tcp.png)

One of the main advantages of using a TCP connection is the possibility to call several actions simultaneously. Stellar keeps a count of the calls, so you can keep track of the different calls in progress.

## TLS

The TCP server supports encrypted connections via TLS, if desired. For this you need to configure some settings on the server:

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

The secure connection can be tested using the following command:

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
  console.log('client', socket.authorized ? 'authorized' : 'not authorized')
})

socket.setEnconding('utf8')
socket.on('data', data => console.log(data))
```

## JSON

The default way to execute actions on Stellar via a TCP connection is using the verbs available for persistent connections. However, it is also possible to use JSON to choose the action to execute and pass a list of parameters. For example, `{"action": "actionName", "params": {"key": "some_value"}}`.
