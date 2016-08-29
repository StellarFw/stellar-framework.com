---
title: Satellites
type: guide
order: 6
---

## Overview

The engine itself does nothing, the only logic that has is that soon as the instance of Stellar is started, is to look for Satellites and load them into memory and execute it.

Satellites are the name given to components that allow you to extend and overwrite Stellar' features. Through this mechanism is possible to isolate the features by area, facilitating the core maintenance, make the framework extremely extensible, and allow developers create modules that can extend features not only from Stellar core but also from other modules.

The entire Stellar core is created by Satellites these loads the basic features of the framework, but the core is not the only place where these components may exist. The modules can also make use of them to load new features, overwrite existing ones, and perform tasks as soon as the framework beings or ends its execution.

## Lifecycle

All Satellites go through a series of stages during the execution of Stellar. Bellow is explained this process and what is done in each of the three stages.

![Satellite Stages](/images/satellite_stages.png)

As can be seen, the picture above shows the three phases of loading a Satellite, they are _load_, _start_, and _stop_. The loading stage is required, while the start and the stop are optional. In the case of being initiated an operation with on end on the start stage, it is recommended you stop that task on the third stage (stop), this because Stellar can restart the server without the process has to finish.

In Satellite loading phase, all the logic must be loading into the API object in order to make the features public, any complex operation should be carried out at this stage, the load must be done as soon as possible. In the initialization phase should begin all continuous tasks, such as servers or some other type of listener. Finally, the stop step all uncompleted pending tasks must be completed, and all servers stopped.

## Format

A Satellite should be a class written following the [ES6](http://www.ecma-international.org/ecma-262/6.0/index.html) standard. The only requirement for the Satellite be loaded by Stellar is contains a `load(api, next)` method. There are other properties which are described below:

- **`loadPriority`**: Allows you change the satellite load order, the default value is 100;
- **`startPriority`**: Allows you change the satellite start order, the default value is 100;
- **`stopPriority`**: Allows you change the satellite stop order,the default value is 100;
- **`load(api, next)`**: Operation to be performed when loading the Satellite;
- **`start(api, next)`**: Operation to be performed when staring the Satellite;
- **`stop(api, next)`**: Operation to be performed when stopping the Satellite.

## Example

```javascript
'use strict'

/**
 * Satellite class.
 *
 * It is recommended to use this class only to specify the functions 
 * of the satellite, any other logic must be written in a class apart.
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
     * @param  {{}}}      api  Reference for the API object.
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
