---
title: HTTP
type: guide
order: 16
---

## Overview

The HTTP server allows you to perform actions and display files using HTTP and HTTPS protocols. The API can be accessed through a browser, cURL command, etc. You can access actions using URLs of the form `<url>?action=<action_name>` or `<url>/api/<action_name>`. For example, if you want to access the `getPost` action on a local server that is listening on port 8080, you would have to make a call to the URL `http://127.0.0.1:8080/api?action=getPosts`.

The JSON below shows an example of a response from the server.

```json
{
  "questions": [ ],
  "serverInformation": {
    "serverName": "Stellar API",
    "apiVersion": "0.0.1",
    "requestDuration": 194,
    "currentTime": 1471702323600
  },
  "requesterInformation": {
    "id": "6f9e36f49e49dd7ac30348a0d9826e367ac747d7-cec5fb6e-2b0b-416e-8529-f897ea666d39",
    "fingerprint": "6f9e36f49e49dd7ac30348a0d9826e367ac747d7",
    "remoteIP": "127.0.0.1",
    "receivedParams": {
      "action": "getQuestions",
      "apiVersion": 1
    }
  }
}
```

## Send Files

Stellar also can serve files to the client. Stellar does not cache files; in each request files are read from disk. The following code is an example of how to send a file to the client from within an action:

```javascript
// specifies the file to send to the client
action.connection.sendFile('/path/to/file.txt')

// informs that isn't to render the response
action.toRender = false

// finish the action execution
next()
```

- The root of web server `/` can be used to serve files (`/files`) or actions (`/api`). Their behavior can be changed using the configuration setting `api.config.servers.web.rootEndpointType` (the default is to serve files).

- When a file is not found the result is a page with an HTTP 404 error.

- Whenever possible the [mime](https://www.npmjs.com/package/mime) package will be used to add a `Content-Type` header in the response.

> Note: see the [File System](./file_system.html) section for more information about sending files.

## Routes

For web clients (HTTP and HTTPS), you can define an optional RESTful mapping to help route requests to actions. If the client doesn't specify an action via a parameter, and the base route isn't a named action, Stellar will attempt to determine the action using the `routes.json` file located in the module's root folder.

There are three ways clients can access actions via a web server:

- No route, using GET parameters: `example.com/api?action=getPosts`

- Through basic routing, where the name of the action is found in the path after `/api`, for example: `example.com/api/getPosts`

- If the `api.config.servers.web.rootEndpointType` setting has the value `'file'` it means that actions must be accessed using the prefix `/api`. For the server to respond to an `example.com/posts` route, `api.config.servers.web.rootEndpointType` must be set to `'api'`.

> Note: when `api.config.servers.web.rootEndpointType` is set to `'api'`, routes starting with `/api` still work.

The JSON below shows an example of a route declaration:

```json
{
  "all": [
    { "path": "/cache/:key/:value", "action": "setCache" }
  ],
  "get": [
    { "path": "/question",      "action": "getQuestions" },
    { "path": "/question/:id",  "action": "getQuestion" }
  ],
  "post": [
    { "path": "/question", "action": "createQuestion" }
  ],
  "put": [
    { "path": "/question/:id", "action": "editQuestion" }
  ],
  "delete": [
    { "path": "/question/:id", "action": "removeQuestion" }
  ]
}
```

### Use Versions

Routes will match the newest version of `apiVersion`. If you want to have a specific route match a specific version of an action, you can provide the `apiVersion` parameter in your route definitions. The following example shows this feature:

```json
{
  "all": [
    { "path": "/actionName/old", "action": "actionName", "apiVersion": 1 },
    { "path": "/actionName/new", "action": "actionName", "apiVersion": 2 }
  ]
}
```

This would create both `/api/actionName/old` and `/api/actionName/new`, mapping to `apiVersion` 1 and 2 respectively.

In your action and middleware, if a route was matched, you can see the details of the match by inspecting `action.connection.matchedRoute` which includes `path` and `action`.

### Disabling Access to `/api`

To disabling access to actions using `/api` and only allow access the actions via the server root, you must change the value of `api.config.servers.web.urlPathForActions` to `null`.

> Note: if you do this, the `api.config.servers.web.rootEndpointType` setting must be set to `'api'`, otherwise there will be no way to make calls to actions.

## Parameters

The parameters can be specified using GET or POST. Parameters are loaded in this order: GET -> POST (normal) -> POST (multipart). This means that if you access URL `example.com/?key=getValue` and you post a variable `key=postValue` as well, `postValue` will be the value used.

File uploads from forms will also appear in `connection.params`, but will be represented as an object with more information. That is, if you uploaded a file called "image", you would have `connection.params.image.path`, `connection.params.image.name` (original file name), and `connection.params.image.type` available to you.

> Note: you can post BODY JSON payloads to Stellar in the form of an object or array.

## Uploading Files

Stellar uses the [formidable](https://www.npmjs.com/package/formidable) form parsing library. You can upload multiple files to an action and they will be available within `connection.params` as a **formidable** response object containing references to the original file name, where the uploaded file was stored temporarily, etc.

## Client Library

Although the Stellar client-side JavaScript library is mostly for WebSockets, it can also be used to make HTTP actions when not connected to a WebSocket (and WebSocket clients will fall back to HTTP requests when disconnected).

```html
<head>
  <!-- (...) -->

  <!-- import Stellar client library  -->
  <script src="//server.example.com/stellar-client">
</head>
```

```javascript
'use strict'

// create a new client
let stellar = new StellarClient({ url: 'server.example.com:8080' })

// call an action
stellar.action('createPost', { title: 'Example!', content: 'Some content...' }, (error, response) => {
  // do something...
})
```

> Note: since we never called `stellar.connect` the request is made via HTTP. More information can be found in the [WebSocket section](./websocket.html).
