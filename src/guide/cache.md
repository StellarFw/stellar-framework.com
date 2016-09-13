---
title: Cache
type: guide
order: 8
---

## Introduction

Stellar comes equipped with a cache system, which is allowed to use numbers, strings, arrays and objects. This is a key-value distributed system which makes use of a Redis server and can use any object that is supported by the `JSON.stringify` function.

## Usage

In the cache system there are three basic methods to manage the cached objects. These are the methods `save`, `load` and `destroy`.

### Add a New Entry

To add a new entry to the cache, you need to use `api.cache.save(key, value, msToExpire, callback)`; this method also allows you to update an existing entry. The `msToExpire` can be `null` if you don't want the object to expire. The `callback` parameter is a function that takes two parameters - `callback(error, newObject)`; the first parameter contains an error if there is one and the second is the newly created object in the cache. If you are updating an existing object, the `newObject` will assume the `true` value.

```javascript
// create a new cache entry
api.cache.save('websiteTitle', 'XPTO Website')
```

> Warning: Once `msToExpire` is reached the entry will be removed from the system, but possibly not at that exact moment.

### Get an Entry

To retrieve an entry which is cached, use the method `api.cache.load(cache, callback)` or `api.cache.load(cache, options, callback)`; `options` must be an object which can contain the property `expireTimeMS` which will reset the expiration time of the cached value when it is read.

```javascript
api.cache.load('webSiteTitle', (error, value, expireTime, createdAt, readAt) => {
  // do something with the value read...
})
```

The `callback` function receive the following parameters:

- **`error`**: Takes the value `null` if there is no error.
- **`value`**: Contains the value corresponding to the requested key, or `null` if the record does not exist in the cache or has expired.
- **`expireTime`**: Time in milliseconds that the object will expire (system time).
- **`createdAt`**: Time in milliseconds in which the object was created.
- **`readAt`**: Time in milliseconds that the object was read for the last time via the `api.cache.load` method; it is useful to know if the object has recently been read by another worker.

### Remove an Entry

To remove a cache entry is as easy as calling the `api.cache.destroy(key, callback)` method.

- **`key`**: Object name to be destroyed.
- **`callback(error, destroyed)`**: Callback function.
  - **`error`**: Contains the error information if there has been a problem.
  - **`destroyed`**: `true` if the object has been destroyed, `false` if the object was not found.


```javascript
api.cache.destroy('webSiteTitle', (error, destroyed) => {
  // do something...
})
```

## Lists

Cache lists have a similar behavior to a queue, the elements are inserted into the tail and removed from the head of the structure. These lists are a great way to store objects that need to be processed in order.

### Insert

To insert a new element in the list we use the `api.cache.push(key, item, callback)` method. If the list already exists the new element will be inserted at the end of the list, otherwise a new list will be created.

- **`key`**: Name of the list where you want to insert the new element.
- **`item`**: Item you want save on the list.
- **`callback(error)`**: Callback function:
  - **`error`**: Takes the `null` value if no error occurred.

```javascript
api.cache.push('commands', {player: 'xpto', command: 'exec:abc:param1'}, error => {
  if (error) {
    // An error occurs...
    return
  }

  // do something...
})
```
> Warning: you can only save objects which are supported by the `JSON.stringify` function.

### Get

To retrieve an element from the list, you can use the `api.cache.pop(key, callback)` method. If the list you are looking for does not exist, it returns the null value, otherwise will get the element present at the head of the list.

- **`key`**: Name of the list from which to get the element.
- **`callback(error, item)`**: Callback function:
  - **`error`**: Takes the `null` value if there is no error in the request.
  - **`item`**: Item present at the head of the list or `null` if the list does not exist.

```javascript
api.cache.pop('commands', (error, item) => {
  if (error) {
    // an error occurs...
    return
  }

  // do something with the item...
})
```

### Size

Stellar also allows you to get the size of a list that is cached. If the list does not exist, the value returned is `0`. For the size you use the `api.cache.listLength(key, callback)` function.

- **`key`**: Name of the list for which you want to obtain the size.
- **`callback(error, size)`**: Callback function:
  - **`error`**: `null` if there is no error with the request.
  - **`size`**: List size.

```javascript
api.cache.listLength('commands', (error, size) => {
  if (error) {
    // an error has occurred!
    return
  }

  // do something with the list size
})
```

## Locking Methods

It is possible, optionally, to use methods to lock editing of objects that are in the cache. These methods are interesting for scenarios where Stellar is running on a cluster, correcting possible concurrency problems.

### Lock

The `api.cache.lock(key, expireTimeMS, callback)` method allows you to lock an existing cached object. The list below describes the parameters of the `lock` method:

- **`key`**: Object name to lock.
- **`expireTimeMS`**: This parameter is optional; by default the value set in the configuration setting `api.config.general.lockDuration` will be used.
- **`callback(error, lockOK)`**: Callback function:
  - **`error`**: Object that contains the error information if an error occurred.
  - **`lockOK`**: Will take the value of `true` or `false`, depending on whether the lock was obtained.

```javascript
api.cache.lock('inTransaction', (error, lockOk) => {
  if (!lockOk) {
    // it was impossible to obtain the lock!
    return
  }

  // do something after getting the lock!
})
```

### Unlock

To unlock an object you just need use the `api.cache.unlock(key, callback)` method. The list below describes the parameters of the `unlock` method:

* **`key`**: Object name to unlock.
* **`callback(error, lockOK)`**: Callback function:
  * **`error`**: `null` if there has been no error, otherwise an object containing the error information.
  * **`lockOK`**: `true` if the lock has been removed, `false` otherwise.

```javascript
api.cache.unlock('inTransaction', (error, lockOk’) => {
  if (!lockOk) {
    // it was impossible to remove the lock!
    return
  }

  // the lock has been removed!
})
```

### Check Lock

There is also a method to obtain the lock status of a particular object, `api.cache.checkLock(key, retry, callback)`. The list below shows the description of the method parameters:

* **`key`**: Object name for which you want check the lock.
* **`callback(error, lockOk)`**: Callback function:
  * **`error`**: `null` unless an error occurred when connecting to the Redis server.
  * **`lockOk`**: `true` or `false` depending on the lock status.

```javascript
api.cache.checkLock('inTransaction', (error, lockOk) => {
  if (!lockOk) {
    // the object does not contain a lock!
    return
  }

  // the object is locked!
})
```

### List of Locks

The `api.cache.locks(callback)` method allows you get all active locks:

* **`callback(error, locks)`**: Callback function:
  * **`error`**: `null` or error information.
  * **`locks`**: Array of all active locks.

```javascript
api.cache.locks((error, locks) => {
  // the variable `locks` is an array that contains 
  // all active locks
})
```
