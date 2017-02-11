Towerbot
========

[![Build Status](https://travis-ci.org/Aplyca/towerbot.svg?branch=master)](https://travis-ci.org/Aplyca/towerbot)
[![Circle CI](https://circleci.com/gh/Aplyca/towerbot.png?style=badge)](https://circleci.com/gh/Aplyca/towerbot)

Conects Hubot, Tower-CLI, Ansible Tower and Slack to make ChatOps. Execute Ansible Tower tasks and send message to Slack

USAGE
-----
Config file
```yaml
# config/towerbot.yml

tower:
  name: My Tower
  hostname: tower.example.com

commands:
  task:
    deploy: 42
```

```coffescript
TowerBot = require('towerbot');
towerbot = new TowerBot(['config/towerbot.yml', 'config/custom.yml']);

module.exports = (robot) ->
  robot.respond /.*\s(task\s+.*)/i, (msg) ->
    towerbot.chat = msg
    try
      data = towerbot.getCommand(msg.match[1])
      task = if data.keywords[1] then data.keywords[1] else throw ({"message": "Task not provided or valid"})

      towerbot.launchTowerJob(
        data.result,
        "",
        "Executing task #{task}"
      )
    catch error
      towerbot.sendErrorToSlack(error)

```

TODOs
----
* Improve docs
* Add support for users of Ansible Tower
* Add Mocha or Jasmine testing libraries


License
-------

MIT / BSD

Author Information
------------------

Mauricio Sánchez from Aplyca SAS (http://www.aplyca.com)
