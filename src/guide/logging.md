---
title: Logging
type: guide
order: 18
---

Stellar makes use of the fantastic [Winston](https://www.npmjs.com/package/winston) package for log management. With Winston it is possible to customize log output according to the needs of your project.

## Providers

In your `config/logger.js` file you can customize which `transports` you would like logger to use. If none are provided, a default logger which only will print to stdout will be used. See Winston's documentation for a list of all logger types; these include console, file, S3, Riak, and more.

```js
'use strict'

exports.logger = {
  transports: [
    api => {
      return new (winston.transports.Console)({
        colorize: true,
        level: 'debug',
      })
    },

    api => {
      return new (winston.transports.File)({
        filename: `./log/${api.pids.title}.log`,
        level: 'info',
        timestamp: true,
      })
    }
  ]
}
```

## Levels

There are 8 levels of logging; each transport can have a different level. The levels are:

- 0 = debug
- 1 = info
- 2 = notice
- 3 = warning
- 4 = error
- 5 = crit
- 6 = alert
- 7 = emerg

> Note: you can customize the levels and colors in the `config/logger.js` file.

For example, if the log level is set to notice, critical messages are visible, but informational and debug messages are not.

```js
// will use the default 'info' level
api.log('hello!')

// will not show up unless you have configured your logger to be debug
api.log('debug message', 'debug')

// will show up in all logger levels
api.log('Bad things happened :(', 'emerg')

// you can log objects too
api.log('the params were', 'info', action.params)
```

## Methods

The `api.logger.log` and `api.logger[severity]` methods are accessible via the `api` object and allow you to modify the Winston instance directly. The `api.log` method passes the message to all transports. Below are some examples of using the `api.log(message, severity, metadata)` method:

```js
// the most basic use - will assume 'info' as the severity
api.log('hello')

// custom severity
api.log('Hmm...', 'warning')

// custom severity with a metadata object
api.log('Red Alert xD', 'emerg', { error: new Error('Some additional information!') })
```
