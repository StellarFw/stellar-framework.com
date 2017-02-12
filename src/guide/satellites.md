---
title: Satellites
type: guide
order: 6
---

## Overview

The Stellar Engine itself does nothing.  The only logic it has is as follows: as soon as an instance of Stellar is started, the Engine looks for Satellites, loads them into memory, and executes them.

Satellites are components that can extend and override Stellar's features. This mechanism organizes Stellar's functionality, facilitates maintenance of the core, makes the framework extremely extensible, and allows developers to create modules that can extend features not only from Stellar's core but also from other modules.

The entire Stellar core is created by Satellites - these load the basic features of the framework, but the core is not the only place where Satellites may exist. Modules can also make use of Satellites to load new features, override existing ones, and perform tasks as soon as the framework begins or ends its execution.

## Lifecycle

All Satellites go through a series of stages during the execution of Stellar. This process, and what occurs in each of the three stages, is explained below.

<div style="margin-left: auto; margin-right: auto; max-width: 80%;">
  ![Satellite Stages](/images/satellite_stages.png)
</div>

The picture above shows the three phases of loading a Satellite: _load_, _start_, and _stop_. The loading stage is required, while the start and the stop are optional. If an operation is initiated in the start stage, it is recommended that the operation be stopped in the third stage (stop).

In the Satellite load phase, all the logic of a Satellite must be loaded into the API object in order to make its features public; any complex operations should be carried out at this stage, and the load must be completed as soon as possible. In the start phase, all continuous tasks should begin, including servers or other types of listener. Finally, in the stop phase, all uncompleted pending tasks must be completed, and all servers must be stopped.

## Format

A Satellite should be a class written following the [ES6](http://www.ecma-international.org/ecma-262/6.0/index.html) standard. The only requirement for the Satellite is that it must contain a `load(api, next)` method. There are other properties which are described below:

- **`loadPriority`**: Allows you change the satellite load order, the default value is 100;
- **`startPriority`**: Allows you change the satellite start order, the default value is 100;
- **`stopPriority`**: Allows you change the satellite stop order,the default value is 100;
- **`load(api, next)`**: Operation to be performed when loading the Satellite;
- **`start(api, next)`**: Operation to be performed when staring the Satellite;
- **`stop(api, next)`**: Operation to be performed when stopping the Satellite.

## Example

```js
'use strict'

/**
 * Satellite class.
 *
 * It is recommended to use this class only to specify the functions
 * of the satellite, any other logic should be contained in a separate class.
 */
exports.default = class {

    /**
     * Constructor.
     *
     * The developer must define the Satellite priority for the
     * different stages.
     */
    constructor () {
      // define the priority for the loading stage
      this.loadPriority = 10
    }

    /**
     * Loading function.
     *
     * @param  {{}}       api  Reference for the API object.
     * @param  {Function} next Callback function.
     */
    load (api, next) {
      // log a message
      api.log('This is awesome!', 'info')

      // finalize the Satellite loading
      next()
    }

}
```
