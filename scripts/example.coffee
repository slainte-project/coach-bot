fs = require 'fs'
path = require 'path'
nlp = require 'nlp_compromise'
delay = 1000
index = 0
current = ''
defaultText = nlp.text("Sorry, that session doesn't exist.").sentences

loadContent = (name) ->  
  try
    filePath = path.join(__dirname, '../narrative/', name+'.md')
    input = fs.readFileSync(filePath, 'utf8')
    sentences = nlp.text(input).sentences
  catch Error
    sentences = defaultText
  sentences

isValidFile = (name) -> 
  filePath = path.join(__dirname, '../narrative/')
  files = fs.readdirSync(filePath)
  isValid = false
  if(files.length > 0)
    for file in files
      if file.indexOf(name) > -1
        isValid = true
  isValid

listSessions = () -> 
  filePath = path.join(__dirname, '../narrative/')
  files = fs.readdirSync(filePath)
  files.map((file) ->
    dotIndex = file.length - 3
    "#"+file.substring(0, dotIndex)
  )

message = (res, message) -> 
  res.send message

isQuestion = (text) ->
  text.indexOf('?') > -1

calculateDelay = (text) -> 
   chunks = nlp.text(text).tags()
   200 * chunks[0].length

talkLoop = (i, res, text) ->
    setTimeout(->
      message(res, text[i].str)
      delay = calculateDelay(text[i].str)
      index += 1
      if (i < text.length - 1 && !isQuestion(text[i].str))
        talkLoop(i + 1, res, text)       
    , delay)

messageWithDelay = (res, message, delay) ->
  setTimeout ( -> 
        res.send message
      ), delay
  
module.exports = (robot) ->

  robot.hear /#(.*)/i, (res) ->
    command = res.match[1]
    if(command != "next" && command != "list")
      current = command
      index = 0
      if(isValidFile(command))
        text = loadContent(command)
      else
        text = defaultText
    else if(command == "list")
      sessions = listSessions()
      text = nlp.text("Available sessions are "+sessions.join()).sentences
    else
      text = loadContent(current)
    if(index < text.length)
      talkLoop(index, res, text)


  # robot.respond /open the (.*) doors/i, (res) ->
  #   doorType = res.match[1]
  #   if doorType is "pod bay"
  #     res.reply "I'm afraid I can't let you do that."
  #   else
  #     res.reply "Opening #{doorType} doors"
  #
  # robot.hear /I like pie/i, (res) ->
  #   res.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (res) ->
  #   res.send res.random lulz
  #
  # robot.topic (res) ->
  #   res.send "#{res.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (res) ->
  #   res.send res.random enterReplies
  # robot.leave (res) ->
  #   res.send res.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if res?
  #     res.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (res) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     res.reply "I'm too fizzy.."
  #
  #   else
  #     res.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'
