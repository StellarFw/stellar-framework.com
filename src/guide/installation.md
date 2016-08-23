---
title: Installation
type: guide
order: 2
---

### Compatibility

Stellar makes use of the full potential of [ECMAScript 6](http://es6-features.org/), so Node.js versions lower than 6 are not supported.

### Release Notes

Details of releases for each version are available on GitHub in the [Releases](https://github.com/StellarFw/stellar/releases) tab and in the [Changelog](https://github.com/StellarFw/stellar/blob/dev/CHANGELOG.md) file.

## NPM

NPM is the recommended method for installing Stellar, since it is used to satisfy not only the dependencies of the core but also the modules.

```bash
# last stable release
$ npm install -g stellar-fw
```

## Development Versions

To use the development version of Stellar you just have to make the clone of GitHub repository. The `master` branch contains the latest stable release of the framework, and the development version are funded on `dev` branch.

```bash
# clone the repository for the stellar folder
$ git clone https://github.com/StellarFw/stellar stellar

# enters the stellar folder and install the dependencies
$ cd stellar && npm install

# does the code transpile from `/src` folder to ES5 code
$ npm run build

# it makes the npm link to add the stellar command-line tool to the system
$ npm link
```

> Note: the `npm link` may require admin permissions.

