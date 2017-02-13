---
title: Testing
type: guide
order: 20
---

## Introduction

Stellar comes with a useful tool to improve the write of your unit testes, as well speed up their execution.

Stellar is built with testing in mind. In fact, support for testing with [Mocha JS](https://mochajs.org) is included out of the box and the command line tool already contains a command to easily run your application tests. The actions and the framework it self was designed to improve the testing experience.

## Environment

When running tests via `stellar test` command, Stellar will automatically set the configuration environment to testing. Stellar also automatically configures, by default, the cache to use an in memory system, as well the database system, meaning no cache or data entry will be persisted while testing. This also improves significantly the tests speed.

You are free to define other testing environment configuration values as necessary. The testing environment variables may be configured in the `/config` folder of your module or application. For that you must use the `development` space, as you can see bellow:

```js
'use strict'

exports.development = {

  app (api) {
    return {
      // your dev configs
    }
  }

}

```

## Creating & Running Tests

To create a new test case, use the `make test` command:

```bash
# create a test in the tests directory
stellar make test user
```





Once the test has been generated, you may define test methods as you normally would using Mocha. To run your tests, simply execute the `stellar test` command from your terminal:

```js
// var to store the Stellar's API object
let api = null

describe('Your awesome feature', () => {

  before(done => {
    // starts the stellar engine
    engine.start((_, a) => {
      api = a
      done()
    })
  })

  after(done => {
    // stops the Stellar engine
    engine.stop(() => { done() })
  })

  it('basic test', done => {
    (true).should.be.true
    done()
  })

})
```
