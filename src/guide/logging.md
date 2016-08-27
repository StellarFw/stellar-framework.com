---
title: Logging
type: guide
order: 12
---

Stellar makes use of the fantastic [Winston](https://www.npmjs.com/package/winston) package for log management. Using Winston is possible to improve and make the system highly customizable logs, due to its high flexibility.

## Providers

In your `config/logger.js` you can customize which `transports` you would like logger to use. If none are provided, a default logger which only will print stdout will be used. See Winston's documentation for all logger types, but know that they include console, file, S3, Riak and more.

```javascript
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

Exists 8 levels of logging, such levels may be used individually by each transport. The levels are:

- 0 = debug
- 1 = info
- 2 = notice
- 3 = warning
- 4 = error
- 5 = crib
- 6 = alert
- 7 = emerg

> Note: you can customize the levels and colors in the `config/logger.js` file.

For example, if the log level is set to notice, critical messages are visible, but informational message and debug are not.

```javascript
// will use the default, 'info' level
api.log('hello!')

// will not show up unless tou have configured your logger in the NODE_ENV to be debug
api.log('debug message', 'debug')

// will show up in all logger levels
api.log('Bad things append :(', 'emerg') 

// you can log object too
api.log('the params were', 'info', action.params)
```

## Methods

The `api.logger.log` and `api.logger[severity]` methods are accessible via `api` object and allow you to modify the instance of Winston directly. The `api.log` method passes the message to all transports. Bellow are some examples of using the `api.log(message, severity, metadata)` method:

```javascript
// the most basic use. Will assume 'info' as the severity
api.log('hello')

// custom severity
api.log('Hmm...', 'warning')

// custom severity with a metadata object
api.log('Red Alert xD', 'emerg', { error: new Error('Some additional information!') })
```
