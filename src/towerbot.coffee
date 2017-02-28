class Towerbot

  constructor: (configFiles = []) ->
    @child_process = require('child_process')
    @config = this.getConfig(configFiles)
    this.log(@config)

  getConfig: (configFiles = []) ->
    yaml = require('js-yaml')
    fs   = require('fs')
    extend = require('extend')
    path = require('path')
    configFiles.unshift(path.join(__dirname, path.normalize('../config/towerbot.yml')));

    config = {}
    for filename in configFiles
      config = extend(true, config, yaml.safeLoad(fs.readFileSync(filename, 'utf8')))

    return config

  expressionsMatch: (regexObject = {}, string = "") ->
    throw ({"message": "Expressions object is not valid"}) if typeof regexObject isnt 'object'

    for expression, value of regexObject
      regex = new RegExp("^"+expression+"$")
      if regex.test(string)
        return value

    throw ({"message": "Expresion #{regex} not matched in string #{string}"})

  getCommand: (ignores = 1, matches = undefined) ->
    this.log(this.msg.match)
    parts = this.msg.match[1].toLowerCase().split /\s+/, matches
    tasks = this.config.commands
    keywords = []
    ignores_counter = 0

    for part in parts
      try
        tasks = this.expressionsMatch(tasks, part)
        keywords.push(part)
        ignores_counter = 0
      catch error
        if ignores_counter >= ignores
          break
        ++ignores_counter

    return { "result": tasks, "keywords": keywords }

  launchTowerJob: (jobTemplate, extraVars, pretext) ->
    @pretext = pretext
    try
      command = "tower-cli job launch --job-template="+jobTemplate+" --extra-vars='"+extraVars+"'"
      result = this.child_process.execSync command, { "env": { "TOWER_FORMAT": "json"}, "encoding": "utf-8" }
    catch error
      this.sendTowerErrorToSlack(jobTemplate, {"title": this.config.tower.name+" job", "message": error.message})
      return

    this.log(result)
    this.sendTowerResultToSlack(JSON.parse(result))

  sendTowerResultToSlack: (result) ->
    fields = [
      {
        "title": this.config.tower.name+" job",
        "value": "<https://"+this.config.tower.hostname+"/#/jobs/"+result.id+"|"+result.id+">",
        "short": true
      },
      {
        "title": "Status",
        "value": result.status,
        "short": true
      }
    ]

    this.sendSuccessToSlack(this.pretext, result.name, result.description, "https://"+this.config.tower.hostname+"/#/job_templates/"+result.job_template, fields)

  sendSuccessToSlack: (pretext = "", title = "", text = "", title_link = "", fields = []) ->
    defaults = this.config.chat.success
    message = {
      attachments: [{
        "pretext": if pretext then pretext else defaults.pretext,
        "title": if title then title else defaults.title,
        "text": if text then text else defaults.text,
        "title_link": title_link,
        "color": "good",
        "fields": if fields then fields else defaults.fields,
      }]
    }

    this.log(message)
    this.msg.send(message)

  sendTowerErrorToSlack: (jobTemplate, error) ->
    this.sendErrorToSlack(error, false, "https://"+this.config.tower.hostname+"/#/job_templates/"+jobTemplate)

  sendErrorToSlack: (error = {}, pretext = false, title_link = false) ->
    message = {
      attachments: [{
        "pretext": if pretext then pretext else this.config.chat.error.pretext,
        "title": if error.title then error.title else this.config.chat.error.title,
        "text": error.message,
        "title_link": title_link,
        "color": "warning"
      }]
    }
    this.log(message)
    this.msg.send(message)

  respond: (robot) ->
    request = this.request.body
    data = if request.payload? then JSON.parse request.payload else request
    channel = data.channel
    this.log(data)
    fields = [
      {
        "title": "Title",
        "value": "http://www.google.com",
        "short": true
      },
      {
        "title": "Status",
        "value": "test #{channel}",
        "short": true
      }
    ]
    message = {
      attachments: [{
        "pretext": "Pretext"
        "title": "Title",
        "text": "text",
        "title_link": "http://www.google.com",
        "color": "good",
        "fields": fields
      }]
    }

    robot.messageRoom channel, message

  log: (text) ->
    console.log(text) if this.config.log

module.exports = Towerbot
