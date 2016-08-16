# Only tested against, 3cx Version 12.5
#
# Make sure to run with the settings.yml file
#
require 'mechanize'
require 'faye/websocket'
require 'eventmachine'
require 'permessage_deflate'
require 'json'
require 'httparty'
require 'websocket/extensions'
require 'mysql'

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
		if JSON.parse(event.data)["key"] != "KeepAlive"
			begin
			con = Mysql.new settings["mysql_host"], settings["mysql_user"], settings["mysql_pass"], settings["mysql_db"]
			con.autocommit false
			
			# You can add and delete variables here
			# Run 3cxraw.rb to see all availible varibles from the 3cx wallboard
			pst = con.prepare "UPDATE wallboard SET avg_talk_time = ?, avg_wait_time = ?, calls_abandoned = ?, calls_answered = ?, calls_serviced_now = ?, calls_waiting = ?, longest_wait_time = ?, timestamp = ? WHERE wallboard_id = 1"
			pst.execute "#{JSON.parse(JSON.parse(event.data)["value"])["AvTalkTime"]["Value"]}", "#{JSON.parse(JSON.parse(event.data)["value"])["AverageWaitingTime"]["Value"]}", "#{JSON.parse(JSON.parse(event.data)["value"])["Unanswered"]["Value"]}", "#{JSON.parse(JSON.parse(event.data)["value"])["Answered"]["Value"]}", "#{JSON.parse(JSON.parse(event.data)["value"])["CallsServicingNow"]["Value"]}", "#{JSON.parse(JSON.parse(event.data)["value"])["CallsInPoll"]["Value"]}", "#{JSON.parse(JSON.parse(event.data)["value"])["LongestWaitTime"]["Value"]}", "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
			con.commit
			
			ensure
			con.close if con
		end
	end
end
}
