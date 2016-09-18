---
title: Development Mode
type: guide
order: 11
---

## What is Development Mode?

Development mode, as the name implies, is a special way to facilitate the development of modules and applications in Stellar. When development mode is active, any change made to the files defining routes, tasks, actions, and models will cause the server to re-read the modified files automatically, eliminating the need to stop and restart the server for every change made. More substantial changes, such as changes to settings and [Satellites](satellites.html), will cause the server to restart completely, but this will also be done automatically in development mode.

To enable development mode you just need create a file (if you do not have one) named `config/api.js` and set the `developmentMode` option to `true`:

```javascript
'use strict'

exports.default = {
  general: api => {
    return {
      developmentMode: true,
    }
  }
}
```

> Warning: the `api.config.general.developmentMode` property is different from the `NODE_ENV` environment variable. The `NODE_ENV` value is considered as `development` by default, but this has no effect on `developmentMode`.

## Effects

When development mode is active, Stellar will re-load [actions](./actions.html), [tasks](./tasks.html), configurations, and [Satellites](satellites.html) when they are modified, all on the fly.

- since Stellar makes use of the `fs.watchFile()` function, the re-load may not work on all operating systems or file systems;
- new files are not loaded, only files that existed when the instance was started will be monitored;
- deleting a file could cause an application crash - Stellar does not attempt to re-load deleted files;
- if the frequency value of a periodic task (`task.frequency`) is changed, it will use the old value until this task is "fired" again;
- changing settings and [Satellites](satellites.html) will cause a full server restart will be made, which will cause all files in the project to be re-loaded, not only the changed files.
