---
title: Cache
type: guide
order: 8
---

## Introduction

Stellar us already equipped with a cache system, is allowed to use numbers, strings, arrays and objects. This is a key-value distributed systems, makes use of a Redis server and can use any object that is supported by `JSON.stringify` function.

## Usage

In the cache system there are three basic methods to manage the cached objects. These are the methods `save`, `load` and `destroy`.

### Add a New Entry

To add a new entry to the cache you need use `api.cache.save(key, value, msToExpire, callback)`, this method also allows update an existing entry. The `msToExpire` can be `null` if you want the object not expire. The `callback` parameter is a function that takes two parameters `callback(error, newObject)`, the first parameter contains an error if there is one and the second is the new created object in the cache. In case you are updating an existent object the `newObject` will assume the `true` value.

```javascript
// create a new cache entry
api.cache.save('websiteTile', 'XPTO Website')
```

> Warning: Once `msToExpire` is reached the entry is removed from the system, but may not match the exact moment.

### Get an Entry

For get an entry who is cached uses the method `api.cache.load(cache, callback)` or `api.cache.load(cache, options, callback)`, the options must be a hash which can contain property `expireTimeMS` which will make the value of the expiration time of the reset, so it is read.

```javascript
api.cache.load('webSiteTitle', (error, value, expireTime, createdAt, readAt) => {
  // do something with the value read...
})
```

The `callback` function receive the follow parameters:

- **`error`**: takes the `null` if there is no error;
- **`value`**: contains the value corresponding to the requested key, or `null` if the record does not exist in the cache or has expired;
- **`expireTime`**: time in milliseconds that the object will expire (system time);
- **`createdAt`**: time in milliseconds in which the object was created;
- **`readAt`**: time in milliseconds that the object was read for the last time via the `api.cache.load`, it is useful to know if the object has recently been consumed by other worker.

### Remove an Entry

To remove a cache entry is easy as calling the `api.cache.destroy(key, callback)` method.

- **`key`**: object name to be destroyed;
- **`callback(error, destroyed)`**: callback function;
  - **`error`**: contains the error information if there has been a problem;
  - **`destroyed`**: `true` if the object has been destroyed, `false` if the object has not been found.


```javascript
api.cache.destroy('webSiteTile', (error, destroyed) => {
  // do something...
})
```

## Lists

The lists have a similar behavior to a queue, the elements are inserted into the tail and removed from the head of the structure. This lists are a great way to store objects that need to be processed in order or later.

### Insert

To insert a new element in the list we resort to the `api.cache.push(key, item, callback)` method. If the list already exists the new element will be inserted at the end of the list, otherwise a new list will be created.

- **`key`**: list name where you want insert the new element;
- **`item`**: item you want save on the list;
- **`callback(error)`**: callback function:
  - **`error`**: takes the `null` value if no error occurred.

```javascript
api.cache.push('commands', {player: 'xpto', command: 'exec:abc:param1'}, error => {
  if (error) {
    // An error occurs...
    return
  }

  // do something...
})
```
> Warning: you can only save object who are supported by the `JSON.stringify` function.

### Get

To a element from the list you use the `api.cache.pop(key, callback)` method. If the list you are looking for does not exist, it returns the null value, otherwise will get the element present in the top of the list.

- **`key`**: list name where to get the element;
- **`callback(error, item)`**: callback function:
  - **`error`**: takes the `null` value if there is no error in the request;
  - **`item`**: item present on the head of the list or `null` if the list does not exist.

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

Stellar also gives the size of a list that is cached. In the case of being made a request of size to a list who not exist, the value returned is `0`. For the size you use the `api.cache.listLength(key, callback)` function.

- **`key`**: list name you want obtain the size;
- **`callback(error, size)`**: callback function:
  - **`error`**: `null` if there is no error with the request;
  - **`size`**: list size.

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

It is possible, optionally, use methods to lock editing of object that are in the cache. These methods are interesting for scenarios where Stellar is running on a cluster, correcting possible concurrence problems.

### Lock

The `api.cache.lock(key, expireTimeMS, callback)` method allows lock an existing cache object. Bellow is a list that describe the parameters of this method:

- **`key`**: object name to be locked;
- **`expireTimeMS`**: this parameter is optional, by default will be used the value set in the configuration file `api.config.general.lockDuration`;
- **`callback(error, lockOK)`**: callback function;
  - **`error`**: object that contains the error information if occurred some;
  - **`lockOK`**: will take the value of `true` or `false`, depending on whether the lock was made.

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

To unlock an object you just need use the `api.cache.unlock(key, callback)` method. The list below explains the parameters of the unlock method:

* **`key`**: object name to unlock;
* **`callback(error, lockOK)`**: callback function;
  * **`error`**: it has the `null` value if there has been no error, otherwise you will have the error information;
  * **`lockOK`**: `true` if the lock has been removed, `false` otherwise.

```javascript
api.cache.unlock('inTransaction', (error, lockOl’) => {
  if (!lockOk) {
    // it was impossible to remove the lock!
    return
  }

  // the lock has been removed!
})
```

### Check Lock

There is also a method to obtain the lock status of a particular object, `api.cache.checkLock(key, retry, callback)`. The list bellow shows the description of the method parameters:

* **`key`**: object name which you want check the lock;
* **`callback(error, lockOk)`**: callback function;
  * **`error`**: `null` unless an error occurred when connecting to the Redis server;
  * **`lockOk`**: `true` or `false` depending on the lock status.

```javascript
api.cache.chechLock('inTransaction', (error, lockOk) => {
  if (!lockOk) {
    // the object does not contain a lock!
    return
  }

  // the object is locked!
})
```

### List of Locks

The `api.cache.locks(callback)` method allows get all active locks on the platform.

* **`callback(error, locks)`**: callback function;
  * **`error`**: `null` or error information;
  * **`locks`**: `array` of all active locks.

```javascript
api.cache.locks((error, locks) => {
  // the variable `locks` is an array that contains 
  // all active locks
})
```
