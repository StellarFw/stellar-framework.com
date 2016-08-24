---
title: File System
type: guide
order: 11
---

## Overview

Stellar is equipped with a file system that allows clients make requests for static files.

If is requested a directory instead of a file, Stellar will look for the file set in `api.config.general.directoryFileType` (which by default is set like `index.html`). If it fails, a not find error will be returned.

You can use the `api.staticFile.get(connection, next)` method in actions to get a file (where `next(connection, error, fileStream, mime, length)`), the file being sought is defined in `connection.params.file`. Note that the fileStream is a stream that can be piped to a client.

> Note: In *NIX operative systems symbolic links to folders and files are allowed.

## Web Clients

In Web client the `Cache-Control` and `Expires` headers are sent, value of these is defined in `api.config.general.flatFileCacheDuration` configuration.

For the `Content-Type` header will be used the [mime](https://npmjs.org/package/mime) to determine the file mime type.

Web clients may request `connection.params.file` directly within an action which makes use of `api.sendFile` method, or if they are under the `api.config.servers.web.urlPathForFiles` route, the file will be looked up as if the route matches the directory structure under `/public` folder.

You can also send the content of a file to a client just use the `server.sendFile(connection, null, stream, 'text/html', length)` method.

## Other Clients

In case you are using a connection that is not web must use the `file` parameter to request a file.

The file content is sent in `raw`, which can be binary or contain line breaks. Must parse according to the type of request you made.

## Send Files by Actions

You can send files through the actions using `connection.sendFile()` method. Bellow is an example of a successful call and another of a failure:

```javascript
// success case
action.connection.sendFile('/path/to/file.mkv')
action.toRender = false
next()

// failure case
action.connection.rawConnection.responseHttpCode = 404
action.connection.sendFile('404.html')
action.toRender = false
next()
```

> Note: You must set the property `action.toRender = false` since it has already sent a reply to the client.
