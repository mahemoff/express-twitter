# GENERAL SETUP
express = require 'express'
sys = require 'sys'
twitter = require '../index.js'

app = express.createServer()

app.use express.cookieParser()
redisStore = require('connect-redis')(express)
app.use express.session
  secret:'randomness'
  store: new redisStore()
  maxAge : new Date(Date.now() + 10*365*24*3600*1000)
app.use twitter.middleware
  consumerKey: "3T3sx20TMn8z1uC2EXWMw" # Use your own key from Twitter's dev dashboard
  consumerSecret: "engeqrh2yyeTdE1BkSzwEs7qozHoWjuP6lt1NDFpBBw" # ditto
  baseURL: 'http://localhost:3000' # Your app's URL, used for Twitter callback
  logging: true # If true, uses winston to log.
  afterLogin: '/hello' # Page user returns to after twitter.com login
  afterLogout: '/goodbye' # Page user returns to after twitter.com logout

app.get '/', (req, res) ->
  message = if req.session.twitter
  then "Ahoy #{req.session.twitter.name}. <a href='/sessions/logout'>Logout</a>"
  else 'Logged out. <a href="/sessions/login">Login Now!</a>'
  res.send "<h3>express-twitter demo</h3><p>#{message}</p>"

app.get '/follow', (req, res) ->
  twitter.postJSON '/friendships/create/mahemoff.json', '', req, (err,data,response) ->
    res.send "Welcome to the universe of infinite rant. Info on user returned: #{sys.inspect data}"

# CAREFUL! The following path will (should!) send an actual tweet as soon as you visit it!
# (Might be open an incognito window and login to that test account.)
app.get '/sendAnActualTweet', (req, res) ->
  twitter.status "Test tweet. Please ignore.", req, (err, data, response) ->
    res.send "Error returned? #{sys.inspect(err)}"

app.get '/hello', (req, res) ->
  res.send """Welcome #{req.session.twitter.name}.<hr/>
    <a href="/sessions/debug">debug</a>  <a href="/you">about you</a>
    <a href="/follow">follow @mahemoff</a> <a href="/sessions/logout">logout</a>"""

app.get '/goodbye', (req, res) ->
  res.send 'Our paths crossed but briefly.'

app.get '/you', (req, res) ->
  twitter.getSelf req, (err, you, response) ->
    res.send "Hello #{you.name}. Twitter says of you:<pre>#{sys.inspect(you)}</pre>"

app.get '/friends', (req, res) ->
  twitter.getFriendIDs req.session.twitter.name, req, (err, friends, response) ->
    res.send "A few friends then. #{sys.inspect friends}"

app.listen 3000
