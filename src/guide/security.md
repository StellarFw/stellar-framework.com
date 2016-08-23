---
title: Security
type: guide
order: 17
---

# Introduction

Stellar comes equipped with a hashing system, which makes use of [bcrypt](https://www.npmjs.com/package/bcrypt) library. This system allows to compute hashes and compare them with clear text data to validate them.

## Compute Hashes

The `api.hash.hash` and `api.hash.hasSync` allows generate a hash from a string asynchronously and synchronously, respectively.

```javascript
// generate a hash synchronously
let hash = api.hash.hashSync(plainData)

// generate a hash asynchronously
api.hash.hash(plainData).then(hash => {
  // do something, with the hash...
})
```

## Compare Hashes

The `api.hash.compare` and `api.hash.compareSync` allows compare a string with a hash to validate if they match.

```javascript
// compare a hash synchronously
let result = api.hash.compare(plainData, hashToCompare)

// compare a hash asynchronously
api.hash.compareSync(plainData, hashToCompare).then(isValid => {
  // do something, with the result...
}) 
```
