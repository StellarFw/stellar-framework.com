---
title: Commands
type: guide
order: 19
---

## Introduction

Stellar comes with a powerful command-line interface. It provides a number of helpful commands that can assist you while you build your application. Each command comes with countless options to customize the command.

![CLI Tool](/images/cli.png)

To view a list of all available commands, you may use the follow command:

```bash
stellar
```

Every command also includes help information which describes the main propose of the command and all available arguments and options. To view a help screen, simply precede the name of the command with `help`, as you can see bellow:

```bash
stellar help run
```

## List of Available Commands

The list below shows all currently available command on Stellar. You can find more information about them on each correspondent page, or simply use the `help` command.

- **completion**: Generate bash completion script
- **console**: Create a REPL connection with a Stellar instance
- **dockerIt**: Create a new dockerfile for an existing stellar  project
- **help**: Show the command description
- **init**: Create a new Stellar project
- **make action**: Create a new action file
- **make listener**: Create a new event listener
- **make model**: Create a new model
- **make task**: Create a new task
- **run**: Run a Stellar instance
- **test**: Run the app tests

> Note: you can execute a command as a daemon using the `--daemon` option. This is useful to start a server instance in production environment.
