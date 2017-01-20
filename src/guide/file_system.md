---
title: File System
type: guide
order: 11
---

## Overview

Stellar is equipped with file system functionality that allows clients to make requests for static files.

If a directory is requested instead of a file, Stellar will look for the file set in `api.config.general.directoryFileType` (which by default is `index.html`). If this file does not exist, a "not found" error will be returned.

You can use the `api.staticFile.get(connection, next)` method in actions to retrieve a file (where the callback parameter has the form `next(connection, error, fileStream, mime, length)`). The file being requested is defined in `connection.params.file`. Note that `fileStream` is a stream that can be piped to a client.

> Note: In \*NIX operating systems symbolic links to folders and files are allowed.

## Web Clients

For Web clients, the `Cache-Control` and `Expires` headers are sent; the value of these is determined by the `api.config.general.flatFileCacheDuration` configuration setting.

For the `Content-Type` header, the [mime](https://npmjs.org/package/mime) package is used to determine the file type.

An action which makes use of the `api.sendFile` method can use `connection.params.file` to find out which file was requested by the client.  If the request falls under the `api.config.servers.web.urlPathForFiles` route, the file will be looked up within the `/public` folder.

You can also send the contents of a file to a client by calling `server.sendFile(connection, null, fileStream, 'text/html', length)`.

## Other Clients

A client using a non-HTTP connection must use the `file` parameter to request a file.

The file content is sent "raw," which can be binary or contain line breaks. The file must be parsed according to the type of request made.

## Send Files by Actions

You can send files from within actions using the `connection.sendFile()` method. Below is an example of a successful call:

```javascript
// success case
action.connection.sendFile('/path/to/file.mkv')
action.toRender = false
next()
```

The following example shows a failure:

```javascript
// failure case
action.connection.rawConnection.responseHttpCode = 404
action.connection.sendFile('404.html')
action.toRender = false
next()
```

> Note: You must set the property `action.toRender = false` after sending a file to prevent Stellar from automatically generating a response, since the response has already been sent to the client.
