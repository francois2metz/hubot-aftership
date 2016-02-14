# Description
#   Track your packages
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot track me <trackingnumber> - Track package
#   hubot track info <id> - get current info for the tracking id
#
# Author:
#   François de Metz

Aftership = require('aftership')(process.env.AFTERSHIP_API_KEY)
url = require('url')
querystring = require('querystring')

module.exports = (robot) ->
  robot.respond /track me (.+)/i, (res) ->
    params =
      body:
        tracking:
          tracking_number: res.match[1]
          custom_fields:
            room: res.room
    Aftership.call 'POST', '/trackings', params, (err, result) ->
      return res.reply("err #{err.message}") if err
      tracking = result.data.tracking
      res.reply "Package tracked. Use track info #{tracking.id}."

  robot.respond /track info (.+)/i, (res) ->
    Aftership.call 'GET', "/trackings/#{res.match[1]}", (err, result) ->
      return res.reply "err #{err.message}" if err
      checkpoints = result.data.tracking.checkpoints.reverse()
      msgs = checkpoints.map (checkpoint) ->
       "- #{checkpoint.checkpoint_time} #{checkpoint.tag} #{checkpoint.message}."
      res.reply msgs.join("\n")

  robot.router.post '/aftership', (req, res) ->
    query = querystring.parse(url.parse(req.url).query)
    data   = if req.body.payload? then JSON.parse req.body.payload else req.body
    secret = query.secret
    return res.status(403).send("NOK") if secret != process.env.AFTERSHIP_SECRET
    room   = data.msg.custom_fields?.room
    return res.status(400).send("NOK") if not room

    checkpoints = data.msg.checkpoints
    msgs = checkpoints.map (checkpoint) ->
       "- #{checkpoint.checkpoint_time} #{checkpoint.tag} #{checkpoint.message}."
    robot.messageRoom room, msgs.join("\n")

    res.send 'OK'
