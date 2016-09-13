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

NPM is the recommended method for installing Stellar and all dependencies.

```bash
# latest stable release
$ npm install -g stellar-fw
```

## Development Versions

To use the development version of Stellar you just have to clone the GitHub repository. The `master` branch contains the latest stable release of the framework; the development version is found in the `dev` branch.

```bash
# clones the repository and creates the stellar folder
$ git clone https://github.com/StellarFw/stellar stellar

# enters the stellar folder and installs the dependencies
$ cd stellar && npm install

# transpiles the ES6 code from the `/src` folder to ES5 code (in the `/dist` folder)
$ npm run build

# adds a symlink in the system npm folder to the stellar command-line tool
$ npm link
```

> Note: the `npm link` command may require admin permissions.

