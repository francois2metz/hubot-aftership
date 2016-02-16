# Description
#   Track your packages
#
# Configuration:
#   AFTERSHIP_API_KEY
#   AFTERSHIP_SECRET
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

translateStatus = (status) ->
  statuses =
    Pending: 'pending'
    InfoReceived: 'info received'
    InTransit: 'in transit'
    OutForDelivery: ':truck:'
    AttemptFail: 'attempt fail'
    Delivered: ':white_check_mark:'
    Exception: ':heavy_exclamation_mark:'
    Expired: 'expired'

  statuses[status]

printTrackingCurrentInfo = (tracking) ->
  ":package: Package #{tracking.id}. Current status is #{translateStatus(tracking.tag)}."

printCheckPointsInfo = (checkpoints)
  msgs = checkpoints.reverse().map (checkpoint) ->
    "- #{moment(checkpoint.checkpoint_time).fromNow()} #{translateStatus(checkpoint.tag)} #{checkpoint.message}."
  msgs.join("\n")

module.exports = (robot) ->
  robot.respond /track me (.+)/i, (res) ->
    params =
      body:
        tracking:
          tracking_number: res.match[1]
          custom_fields:
            room: res.message.room
    Aftership.call 'POST', '/trackings', params, (err, result) ->
      return res.reply("err #{err.message}") if err
      tracking = result.data.tracking
      res.reply ":package: Package tracked. Use track info #{tracking.id}."

  robot.respond /track info (.+)/i, (res) ->
    Aftership.call 'GET', "/trackings/#{res.match[1]}", (err, result) ->
      return res.reply "err #{err.message}" if err
      tracking = result.data.tracking
      res.reply printTrackingCurrentInfo(tracking) + "\n" + printCheckPointsInfo(tracking.checkpoints)

  robot.router.post '/aftership', (req, res) ->
    query = querystring.parse(url.parse(req.url).query)
    data   = if req.body.payload? then JSON.parse req.body.payload else req.body
    secret = query.secret
    return res.status(403).send("NOK") if secret != process.env.AFTERSHIP_SECRET
    return res.status(200).send("OK") if data.msg.id == "000000000000000000000000"
    room   = data.msg.custom_fields?.room
    return res.status(400).send("NOK") if not room

    tracking = data.msg
    robot.messageRoom room, printTrackingCurrentInfo(tracking) + "\n" + printCheckPointsInfo([tracking.checkpoints.reverse()[0]])

    res.send 'OK'
