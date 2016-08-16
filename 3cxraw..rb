#This file will ONLY print to screen the variables availible from the 3cx Wallboard.
#
require 'mechanize'
require 'faye/websocket'
require 'eventmachine'
require 'permessage_deflate'
require 'json'
require 'httparty'
require 'websocket/extensions'

config_file = ARGV[0]
settings = YAML.load_file(config_file)
wallboard_url = settings["3cx_wallboard_host"]+":"+settings["3cx_wallboard_port"]
wallboard_ws = settings["3cx_wallboard_host"]+":"+settings["3cx_websocket_port"]
queue = {"key" => "QueueID", "value" => settings["queue"]}

agent = Mechanize.new
agent.user_agent_alias = 'Mac Safari'
agent.get("http://#{wallboard_url}/Wallboard/Account/Login.aspx") do | home_page |
  login_form = home_page.form_with(:id => "LoginForm")
  @params = Hash.new
  login_form.fields.each { |f| @params[f.name] = f.value }
  @params["ctl00$MainContent$LoginUser$UserName"]    = settings["username"]
  @params["ctl00$MainContent$LoginUser$Password"]    = settings["password"]
  @params["ctl00$MainContent$LoginUser$LoginButton"] = settings["loginbutton"]
  @params["ctl00$MainContent$LoginUser$Queue"]       = settings["queue"]
end
  agent.post "http://#{wallboard_url}/Wallboard/Account/Login.aspx", @params, 'Content-Type' => 'application/x-www-form-urlencoded'
  cookies = agent.cookie_jar.store.map {|i| i}
EM.run {
  url="ws://#{wallboard_ws}/Wallboard"
  ws = Faye::WebSocket::Client.new(url, [], :headers => { 'Cookie' => cookies.join(';')})
  ws.on :open do |event|
    ws.send queue.to_json
  end
  ws.on :message do |event|
    #p [event.data]
    if JSON.parse(event.data)["key"] != "KeepAlive"
		puts "AbandonRate: #{JSON.parse(JSON.parse(event.data)["value"])["AbandonRate"]["Value"]}"
		puts "Answered: #{JSON.parse(JSON.parse(event.data)["value"])["Answered"]["Value"]}"
		puts "AvTalkTime: #{JSON.parse(JSON.parse(event.data)["value"])["AvTalkTime"]["Value"]}"
		puts "AverageWaitingTime: #{JSON.parse(JSON.parse(event.data)["value"])["AverageWaitingTime"]["Value"]}"
		puts "CallsExpired: #{JSON.parse(JSON.parse(event.data)["value"])["CallsExpired"]["Value"]}"
		puts "CallsInPoll: #{JSON.parse(JSON.parse(event.data)["value"])["CallsInPoll"]["Value"]}"
		puts "CallsServicingNow: #{JSON.parse(JSON.parse(event.data)["value"])["CallsServicingNow"]["Value"]}"
		puts "CallsWaiting: #{JSON.parse(JSON.parse(event.data)["value"])["CallsWaiting"]["Value"]}"
		puts "DroppedByQMCalls: #{JSON.parse(JSON.parse(event.data)["value"])["DroppedByQMCalls"]["Value"]}"
		puts "DroppedInPoll: #{JSON.parse(JSON.parse(event.data)["value"])["DroppedInPoll"]["Value"]}"
		puts "DroppedInWait: #{JSON.parse(JSON.parse(event.data)["value"])["DroppedInWait"]["Value"]}"
		puts "LongestWaitTime: #{JSON.parse(JSON.parse(event.data)["value"])["LongestWaitTime"]["Value"]}"
		puts "TotalCalls: #{JSON.parse(JSON.parse(event.data)["value"])["TotalCalls"]["Value"]}"
		puts "TotalCallsReachedMaxTime: #{JSON.parse(JSON.parse(event.data)["value"])["TotalCallsReachedMaxTime"]["Value"]}"
		puts "TotalTalkTime: #{JSON.parse(JSON.parse(event.data)["value"])["TotalTalkTime"]["Value"]}"
		puts "TotalTransfersFailed: #{JSON.parse(JSON.parse(event.data)["value"])["TotalTransfersFailed"]["Value"]}"
		puts "TotalUserRequestedEnd: #{JSON.parse(JSON.parse(event.data)["value"])["TotalUserRequestedEnd"]["Value"]}"
		puts "Unanswered: #{JSON.parse(JSON.parse(event.data)["value"])["Unanswered"]["Value"]}"
    end
  end
}
