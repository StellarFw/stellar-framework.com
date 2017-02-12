---
title: Tasks
type: guide
order: 4
---

## Overview

Tasks are jobs performed separately from client requests. They can be initialized by an action or by the server itself. With Stellar, there is no need to separately execute a daemon to process the work. Stellar uses the `node-resque` package for storing and processing tasks. In Stellar there are three ways of processing tasks: `normal`, `delayed` and `periodic`. In `normal` processing, the tasks are queued one by one by the `TaskProcessor`. When the task is `delayed`, it is inserted in a special queue which will be processed at a certain time in the future; the delay is set in milliseconds from the time of insertion or through a timestamp. Finally, `periodic` tasks are similar to `delayed` tasks, but `periodic` tasks are executed repeatedly with a certain frequency.

> Note: It is recommended to use tasks for sending emails and other operations that can be performed asynchronously in order to shorten client responses.

## Types of Tasks

This subsection demonstrates the types of tasks that exist and how they can be used.

First, we have the `normal` tasks. Tasks of this type are added to a queue and processed in order of arrival as soon as there are free workers.

```js
// api.tasks.enqueue(taskName, args, queue, callback)
api.tasks.enqueue('sendResetPasswordEmail', { to: 'gil00mendes@gmail.com' }, 'default', (error, toRun) => {
  // task enqueued!
})
```

Then we have the `delayed` tasks. These tasks are enqueued in a special 'delayed' queue to be processed at some time in the future (defined either by a timestamp or a number of milliseconds from the time the task is created):

```js
// api.tasks.enqueueAt(timestamp, taskName, args, queue, callback)
api.tasks.enqueueAt(1591629508, 'sendNotificationEmail', { to: 'gil00mendes@gmail.com' }, 'default', (error, toRun) => {
  // task enqueued!
})
```

Finally, `periodic` tasks are like `delayed` tasks, but they run on a set frequency (e.g., every 5 minutes):


```js
// api.tasks.enqueueIn(delay, taskName, args, queue, callback)
api.tasks.enqueueIn(60000, 'sendNotificationEmail', { to: 'gil00mendes@gmail.com' }, 'default', (error, toRun) => {
  // task enqueued!
})
```

> Note: Periodic tasks can take no input parameters.

## Create an Task

The actions are stored in the `/tasks` folder inside each module. To generate a new task you can run the command: `stellar makeTask <task_name> --module=<module_name>`. A task has some mandatory properties, which are described in the next section.

### Properties

The list below are the properties supported by the tasks. The properties `name`, `description`, and `run` are mandatory.

- **`name`**: Name of the task, which must be unique.
- **`description`**: Must contain a short description of the purpose of the task.
- **`queue`**: `Queue` which will run the task, by default this property is set to `default`. This value can be replaced when using the `api.tasks.enqueue` methods.
- **`frequency`**: If the value is greater than zero, the task will be considered a periodic task and will run once every interval specified by the number of milliseconds defined in this property.
- **`plugins`**: In this property you can define an array of resque plugins; these plugins modify how tasks are inserted in the queue. You can read more about this in the [node-resque](https://github.com/taskrabbit/node-resque) docs.
- **`pluginOptions`**: This is an object with options for plugins.
- **`run(api, params, next)`**: A function that implements the operations to be performed by the task.

> Note: for the task name it is recommended to use a namespace; e.g., `auth.sessionValidation`.

### Example

The example below shows the structure of a task which records a message "Hello!!!" every second:

```js
exports.sayHello = {
  name: 'sayHello',
  description: 'I say hello',
  queue: 'default',
  frequency: 1000,

  run (api, params, next) {
    // log a new message
    api.log('Hello!!!')

    // finish the task execution
    next()
  }
}
```
## Task Management

Stellar has a number methods which allow you to manage and query the state of the task queues.

### Remove a Task

Remove all tasks which match the given parameters - `api.tasks.del(queue, taskName, args, count, callback)`:

- **`queue`**: Name of the queue from which the task(s) must be removed.
- **`taskName`**: Task name to be removed.
- **`args`**: Search arguments (for more information on this you can read the `node-resque` documentation).
- **`count`**: Number of task instances which must be removed.

### Remove a Task with Delay

Remove all tasks with delay which match the given parameters - `api.tasks.delDelayed(queue, taskName, args, callback)`:

- **`queue`**: Name of the queue from which the task(s) must be removed.
- **`taskName`**: Task name to be removed.
- **`args`**: Search arguments (more information about this can be found in the `node-resque` documentation).

### Clean a Queue

The `api.tasks.delQueue(queue, callback)` method removes all the tasks in a queue:

- **`queue`**: Queue name where the tasks must be all removed.

### Recurrent Jobs

The `api.tasks.enqueueRecurrentJob(taskName, callback)` method allows you add a new recurrent job:

- **`taskName`**: Task name to be added.

### Stop Recurrent Jobs

The `api.tasks.stopRecurrentJob(taskName, callback)` method allows you stop a recurrent job:

- **`taskName`**: Task name to be removed from the recurrent queue.

### Tasks with Timestamps

The `api.tasks.timestamps(callback)` method allows you get an array with all tasks with an associated timestamp.

### Statistics

The `api.tasks.stats(callback)` method allows you to get an array with all statistics of the resque cluster.

### Locks

The `api.tasks.locks(callback)` method allows you to get an array with all existing locks in the cluster.

### Remove a Lock

The `api.tasks.delLock(lockName, callback)` method allows you to remove a lock from the cluster:

- **`lockName`**: Lock name to be removed.
- **`callback(removed, error)`**: Callback function.
  - **`removed`**: Set to `1` if the lock as been removed.
  - **`error`**: `Error` instance if an error occurs during the request.

### Remove Tasks on a Timestamp

The `api.tasks.delDelayesAt(timestamp, callback)` method removes all tasks on the requested timestamp:

- **`timestamp`**: Timestamp for the tasks that must be removed.

### Remove all Tasks with Delay

The `api.tasks.allDelayed(callback)` method allows you to remove all tasks with delay.

### Get Workers

The `api.tasks.workers(callback)` method allows you to get all `TaskProcessors` instances.

### Details

The `api.tasks.details(callback)` method allows you to get information about the existing queues.

### Failed Count

The `api.tasks.failedCount(callback)` method allows you to get the number of failed jobs.

### Remove a Failed Job

The `api.tasks.removeFailed(failedJob, callback)` method allows you remove a task from the failed jobs queue.

### Retry a Failed Job

The `api.tasks.retryAndRemoveFailed(failedJob, callback)` method allows you to retry failed task and remove that task from the failed jobs queue.

- **`failedJob`**: Task name.

## Failed Job Management

Periodic tasks cannot receive input parameters. Sometimes a worker crashes is a severe way, and it doesn't have a chance to notify Redis that it is leaving the pool (this happens often on PaaS like Heroku). When this happens, you will not only need to extract the job from the now-dead worker's "working on" status, but also remove the stuck worker. To aid you in these edge cases, `api.tasks.cleanOldWorkers(age, callback)` is available.

Because there are no 'heartbeats' in resque, it is impossible for the application to know whether a worker has been working on a long job or it is dead.
