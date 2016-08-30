---
title: Tasks
type: guide
order: 4
---

## Overview

Tasks are jobs performed apart of the client requests. They can be initialized by an action or by the server itself. With Stellar, there is no need of separately execute a daemon to process the work. Stellar uses the `node-resque` package for storing and processing tasks. In Stellar there are three ways of processing tasks: `normal`, `late` and `periodically`. In normal processing, the tasks are queued one by one by the `TaskProcessor`. When the task is executed with a delay, it is inserted in a special queue for the propose, which will be processed at a time in the future, the delay is set in milliseconds from the time of insertion or through a timestamp. Finally, periodic tasks are similar to tasks with delay, but are executed with a certain frequency.

> Note: It is recommended the use of task for sending emails and other operation that can be performed asynchronously in order to shorten the client responses.

## Types of Tasks

This subsection sets out some more of the types of tasks that exist and how they can be used.

First, we have the `normal` tasks. This type of task is added to a queue and processed in order of arrival as soon as there are free workers.

```javascript
// api.tasks.enqueue(taskName, args, queue, callback)
api.tasks.enqueue('sendResetPasswordEmail', { to: 'gil00mendes@gmail.com' }, 'default', (error, toRun) => {
  // task enqueued!
})
```

Then we have the `delayed` tasks. These tasks are enqueued in a special 'delayed' queue to only be processed at some time in the future (defined either by a timestamp in ms or miliseconds-from-now):

```javascript
// api.tasks.enqueueAt(timestamp, taskName, args, queue, callback)
api.tasks.enqueueAt(1591629508, 'sendNotificationEmail', { to: 'gil00mendes@gmail.com' }, 'default', (error, toRun) => {
  // task enqueued!
})
```

Finally, `periodic` tasks are like delayed tasks, but they run on a set frequency (ex. every 5 minutes):


```javascript
// api.tasks.enqueueIn(delay, taskName, args, queue, callback)
api.tasks.enqueueIn(60000, 'sendNotificationEmail', { to: 'gil00mendes@gmail.com' }, 'default', (error, toRun) => {
  // task enqueued!
})
```

> Note: Periodic tasks can take no input parameters.

## Create an Task

The actions are stored in the `/tasks` folder inside of each module. To generate a new task you can use the command line tool by running the command: `stellar makeTask <task_name> --module=<module_name>`. The tasks has some mandatory properties, you can find more information on this subject in the following subchapter.

### Properties

The list below are the properties supported by the tasks. The property, `name`, `description`, and `run` are mandatory.

- **`name`**: Name of the task, it must me unique;
- **`description`**: Must contain a short description of the purpose of the task;
- **`queue`**: `Queue` which will run the task, by default this property is set to `default`. This value can be replaced when using the `api.tasks.enqueue` methods;
- **`frequency`**: If the value is greater than zero, will be considered a periodic tasks and runs every passing milliseconds defined in this property;
- **`plugins`**: In this property you can defined an array of resque plugins, these plugins modify how the task are inserted in the queue. Toy can read more about this in the [node-resque](https://github.com/taskrabbit/node-resque) docs;
- **`pluginOptions`**: This is a hash with options for plugins;
- **`run(api, params, next)`**: functions that contains the operations to be performed by the task.

> Note: for the task names declaration is recommended using a namespace, for example `auth.sessionValidation`.

### Example

The example below shows the structure of a task, it records a message "Hello!!!" every 1 second:

```javascript
exports.sayHello = {
  name: 'sayHello',
  description: 'I say hello',
  queue: 'default',
  frequency: 1000,

  run: (api, params, next) => {
    // log a new message
    api.log('Hello!!!')

    // finish the task execution
    next()
  }
}
```
## Task Management

Stellar has some methods who allow you manage and verify the queues states. Down bellow are some methods to manage the tasks.

### Remove a Task

Remove all tasks who match with the given parameters `api.tasks.del(queue, taskName, args, count, callback)`:

- **`queue`**: name of the queue where the command must be executed;
- **`taskName`**: task name to be removed;
- **`args`**: search arguments (to more information on this you can read the `node-resq` docs);
- **`count`**: number of task instances who most be removed.

### Remote a Task with Delay

Remove all tasks with delay who match with the given parameters `api.tasks.delDelayed(queue, taskName, args, count, callback)`:
  
- **`queue`**: name of the queue where the command must be executed;
- **`taskName`**: task name to be deleted;
- **`args`**: search arguments (more information about this can be found on the `node-resq` documentation)

### Clean a Queue

The `api.tasks.delQueue(queue, callback)` method remove all the task in a queue:

- **`queue`**: queue name where the task must be all removed.

### Recurrent Jobs

The `api.tasks.enqueueRecurrentJob(taskName, callback)` method allows you add a new recurrent job:

- **`taskName`**: task name to be added.

### Stop Recurrent Jobs

The `api.tasks.stopRecurrentJob(taskName, callback)` method allows you stop a recurrent job:

- **`taskName`**: task name to be removed from the recurrent queue.

### Tasks with Timestamps

The `api.tasks.timestamps(callback)` method allows you get an array with all tasks with an associated timestamp.

### Statistics

The `api.tasks.stats(callback)` method allows you to get an array with all statistics of the reques cluster.

### Locks

The `api.tasks.locks(callback)` method allows you to get an array with all existing locks in the cluster.

### Remove a Lock

The `api.tasks.delLock(lockName, callback)` method allows you to remove a lock from the cluster:

- **`lockName`**: lock name to be removed;
- **`callback(removed, error)`**: callback function:
  - **`removed`**: set to `1` if the lock as been removed;
  - **`error`**: `Error` instance in the case of an error occurs during the request.

### Remove Tasks on a Timestamp

O `api.tasks.delDelayesAt(timestamp, callback)` method remove all tasks on the requested timestamp:

- **`timestamp`**: timestamp where the tasks must be removed.

### Remove all Tasks with Delay

The `api.tasks.allDelayed(callback)` allows you to remove all tasks with delay.

### Get Workers

The `api.tasks.workers(callback)` method allows you to get all `TaskProcessors` instances.

### Details

The `api.tasks.details(callback)` method allows you to get a list of informations about the existing queues.

### Failed Count

The `api.tasks.failedCount(callback)` method allows you to get the number of failed jobs.

### Removes a Failed Job

The `api.tasks.removeFailed(failedJob, callback)` method allows you remove a tasks from the failed jobs queue.

### Try Execute a Failed Job, Again

The `api.tasks.retryAndRemoveFailed(failedJob, callback)` method allows you back trying to run a failed task and remove that from the queue who contains the failed jobs.

- **`failedJob`**: task name.

## Failed Job Management

Periodic tasks can not receive input parameters. Sometimes workers crashes is a severe way, and it doesn't get the time/chance to notify Redis that it is leaving the poll (this happens all the time on PASS like Heroku). When this happens, you will not only need to extract the job from the now-dead worker's "working on" status, but also remove the stuck worker. To aid you in these edges cases, `api.tasks.cleanOldWorkers(age, callback)` is available.

Because there are no 'heartbeats' in resque, it is impossible for the application to know if a worker has been working on a long job or it is dead.