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

To add a new entry to the cache, you need to use `api.cache.save(key, value, msToExpire)`; this method also allows you to update an existing entry. The `msToExpire` can be `null` if you don't want the object to expire. As return this method give us a `Promise` with the newly created object in the cache. If you are updating an existing object, the value will assume the `true` value.

```js
// create a new cache entry
await api.cache.save('websiteTitle', 'XPTO Website')
```

> Warning: Once `msToExpire` is reached the entry will be removed from the system, but possibly not at that exact moment.

### Get an Entry

To retrieve an entry which is cached, use the method `api.cache.load(cache)` or `api.cache.load(cache, options)`; `options` must be an object which can contain the property `expireTimeMS` which will reset the expiration time of the cached value when it is read.

```js
// try get the `webSiteTitle` entry from the cache.
const data = await api.cache.load('webSiteTitle')
```

When the `Promise` is resolved it give an object with the following parameters:

- **`value`**: Contains the value corresponding to the requested key, or `null` if the record does not exist in the cache or has expired.
- **`expireTime`**: Time in milliseconds that the object will expire (system time).
- **`createdAt`**: Time in milliseconds in which the object was created.
- **`readAt`**: Time in milliseconds that the object was read for the last time via the `api.cache.load` method; it is useful to know if the object has recently been read by another worker.

### Remove an Entry

To remove a cache entry is as easy as calling the `api.cache.destroy(key)` method.

- **`key`**: Object name to be destroyed.

```js
await api.cache.destroy('webSiteTitle')
```

## Lists

Cache lists have a similar behavior to a queue, the elements are inserted into the tail and removed from the head of the structure. These lists are a great way to store objects that need to be processed in order.

### Insert

To insert a new element in the list we use the `api.cache.push(key, item)` method. If the list already exists the new element will be inserted at the end of the list, otherwise a new list will be created.

- **`key`**: Name of the list where you want to insert the new element.
- **`item`**: Item you want save on the list.

```js
// add a new element on the `commands` list
await api.cache.push('commands', {player: 'xpto', command: 'exec:abc:param1'})
```
> Warning: you can only save objects which are supported by the `JSON.stringify` function.

### Get

To retrieve an element from the list, you can use the `api.cache.pop(key)` method. If the list you are looking for does not exist, it returns the null value, otherwise will get the element present at the head of the list.

- **`key`**: Name of the list from which to get the element.

The following example shows how to pop a element from a list. When the `Promise` resolves it give us the item present at the head of the list or `null` if the list does not exist.

```js
// pop an element from the list and save it on the `item` const
const item = await api.cache.pop('commands')
```

### Size

Stellar also allows you to get the size of a list that is cached. If the list does not exist, the value returned is `0`. For the size you use the `api.cache.listLength(key)` function.

- **`key`**: Name of the list for which you want to obtain the size.

```js
// get the `commands` list size and store it on a constant
const size = await api.cache.listLength('commands')
```

## Locking Methods

It is possible, optionally, to use methods to lock editing of objects that are in the cache. These methods are interesting for scenarios where Stellar is running on a cluster, correcting possible concurrency problems.

### Lock

The `api.cache.lock(key, expireTimeMS)` method allows you to lock an existing cached object. The list below describes the parameters of the `lock` method:

- **`key`**: Object name to lock.
- **`expireTimeMS`**: This parameter is optional; by default the value set in the configuration setting `api.config.general.lockDuration` will be used.

The returned promise after resolved give us a boolean value informing whether the lock was obtained.

```js
const lockOk = await api.cache.lock('inTransaction')

if (!lockOk) {
  // it was impossible to obtain the lock!
  return
}

// do something after getting the lock!
```

### Unlock

To unlock an object you just need use the `api.cache.unlock(key)` method. The list below describes the parameters of the `unlock` method:

* **`key`**: Object name to unlock.

The returned promise after be resolved give us a boolean value, `true` if the lock has been removed, `false` otherwise.

```js
const lockOk = await api.cache.unlock('inTransaction')

if (!lockOk) {
  // it was impossible to remove the lock!
  return
}

// the lock has been removed!
```

### Check Lock

There is also a method to obtain the lock status of a particular object, `api.cache.checkLock(key, retry)`. The list below shows the description of the method parameters:

* **`key`**: Object name for which you want check the lock.

The returned promise after be resolved give us a boolean value, `true` or `false` depending on the lock status.

```js
const lockOk = await api.cache.checkLock('inTransaction')

if (!lockOk) {
  // the object does not contain a lock!
  return
}

// the object is locked!
```

### List of Locks

The `api.cache.locks()` method allows you get all active locks.

```js
// with this lock we can obtain the list of all locks currently in the system
const locks = await api.cache.locks()
```
