---
title: Development Mode
type: guide
order: 10
---

## What is?

The developer mode, as the name implies, is a special way to facilitate the development of modules and applications in Stellar. By changing the file routes, tasks, actions and models, the server can override this logic in memory as soon as it detected a change in the file system. Thus not have to be constantly stop and re-run the server every change made. More severe changes, such as settings and [Satellites](satellites.html) cause the server to restart completely, but everything is fone automatically.

To enable development mode you just need create a file (if you do not have one) `config/api.js` and set the `developmentMode` option to `true`:

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

> Warning: the `api.config.general.developmentMode` property is different from `NODE_ENV`. The environment only informs Stellar which settings must be used. By default is development, but no effect on `developmentMode`.

## Effects

When the development mode is active Stellar will re-load [actions](./actions.html), [tasks](./tasks.html), configurations, and [Satellites](satellites.html) as they are modified, all on the fly.

- since Stellar makes use of `fs.watchFile()` function, the re-load may not work on all operative systems/file systems;
- new files are not loaded, only files that the instance was started will be monitored;
- delete a file could cause an application crash, Stellar does not attempt to re-load deleted files;
- if the frequency value if a periodic task (`task.frequency`) is changed, it will use the old value until this task id "fired" again;
- change settings and [Satellites](satellites.html), a full server restart will be made, and not only the changed files.
