---
title: HTTP
type: guide
order: 16
---

## Overview

The HTTP server allows you to perform actions and display files in HTTP and HTTPS protocols. The API can be accessed through a browser, CURL command, etc. Via `<url>?action=<action_name>` or `<url>/api/<action_name>` is where you can access the actions. For example, if you want to access the `getPost` action on a local server that is listening on port 8080, you would have to make a call to the URL `http://127.0.0.1/?action=getPosts`.

The JSON code below shows an example of a response from the server.

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

Stellar also can serve files to the client. The Stellar does not cache files, in each request files are read from disk. The following code is an example of how to serve a customer file from an action:

```javascript
// specifies the file to send to the client
action.connection.sendFile('/path/to/file.txt')

// informs that isn't to render the response
action.toRender = false

// finish the action execution
next()
```

- The root of web server `/` can be used to serve files (`/files`) or actions (`/api`). Their behavior can be changed in `api.config.servers.web.rootEndpointType`, by default serves files.

- When a file is not found the result is a page with the HTTP 404 error.

- Whenever possible will be resorted to [mime](https://www.npmjs.com/package/mime) package to add an entry in the header of the answer to the `mime-type` type of the server file.

> Note: in the [File System](./file_system.html) section can be found some helpers for sending files.

## Routes

For web client (HTTP and HTTPS), you can define an option RESTful mapping to help route requests to actions. If the client doesn't specify an action via a param, and the base route isn't a named action, the action will attempt to be discerned from the `routes.json` located in the modules root folder.

There are three ways to clients access actions via a web server:

- no route, using GET parameters: `example.com/api?action=getPosts`

- through basic routing, where the name of the action will respond after the path `/api`, for example: `example.com/api/getPosts`

- If `api.config.servers.web.rootEndpointType` setting has the value `'file'` it means that the routes will respond on the prefix `/api`. For the server responds on `example.com/posts` route, `api.config.servers.web.rootEndpointType` must be set to `'api'`.

> Note: chaining the configuration `'file'` to `'api'` routes in `/api` still work

The JSON below shows an example of the route declaration:

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

Routes will match the newest version of `apiVersion`. If you want to have a specific route match a specific version of an action, you can provide the `apiVersion` parameter in your route definitions. The follow example shows that feature:

```json
{
  "all": [
    { "path": "/actionName/old", "action": "actionName", "apiVersion": 1 },
    { "path": "/actionName/new", "action": "actionName", "apiVersion": 2 }
  ]
}
```

This would create both `/api/actionName/old` and `/api/actionName/new`, mapping to apiVersion 1 and 2 respectively.

In your action and middleware, if a route was matched, you can see the details of the match by inspecting `action.connection.matchedRoute` which include `path` and `action`.

### Disabling Access to `/api`

To disabling accessing in `/api` and is only able to access the actions by the server root, you must change the value of `api.config.servers.web.urlPathForActions` to `null`.

> Note: the `api.config.servers.web.rootEndpointType` parameter should be equal to `'api'`, otherwise you can not make calls to actions.

## Parameters

The parameters can be specified using GET or POST. Parameter are loaded in this order GET -> POST (normal) -> POST (multipart). This means that if you are `exmaple.com/key=getValue` and you post a variable `key=postValue` as well, the `postValue` will be the one used.

File uploads from forms will also appear in `connection.params`, but will be an object with more information. That is, if you uploaded a file called "image", you would have `connection.params.image.path`, `connection.params.image.name` (original file name), and `connection.params.image.type` available to you.

> Note: you can post BODY json payloads to Stellar in the form of a hash or array.

## Uploading Files

Stellar uses the [formidable](https://www.npmjs.com/package/formidable) form parsing library. You can upload multiple files to an action and they will be available within `connection.params` as **formidable** response object containing references to the original file name, where the uploaded file was stores temporarily, etc.

## Client Library

Although the StellarClient client-side library is mostly for WebSockets, it can now be used to make HTTP actions when not connect (and WebSockets clients will fall back to HTTP actions when disconnected).

```html
<head>
  <!-- (...) -->

  <!-- import Stellar client library  -->
  <script src="//server.example.com/client-lib">
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

> Note: once we never called `stellar.connect` the request are make by HTTP action. More information can be found on the [WebSocket docs page](./websocket.html).
