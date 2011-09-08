# GENERAL SETUP
express = require 'express'
twitter = require '../index.js'

app = express.createServer()

app.use express.cookieParser()
app.use express.session { secret:'randomness' }
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

app.get '/hello', (req, res) ->
  res.send """Welcome #{req.session.twitter.name}.<hr/>
    <a href="/sessions/debug">debug</a>  <a href="/you">about you</a>
    <a href="/logout">logout</a>"""

app.get '/goodbye', (req, res) ->
  res.send 'Our paths crossed but briefly.'

app.get '/you', (req, res) ->
  twitter.get 'http://twitter.com/account/verify_credentials.json', req, (err, data, response) ->
    user = JSON.parse(data)
    res.send "Hello #{user.name}. Twitter says of you:<pre>#{sys.inspect(user)}</pre>"

app.listen 3000
