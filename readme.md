# 3cx Wallboard Websocket
Connects to the websocket of the 3cx wallboard and writes data to a mysql database

## How to run
I ran this on my CentOS 6 web server, from the command line:
<br>/path/to/ruby /path/to/3cx.rb /path/to/settings.yml

## Other Info
I am running Ruby 2.1.0 on CentOS 6 (all the latest updates)

Make sure the following Ruby libraries are installed:
<ul>
<li>mechanize</li>
<li>faye-websocket</li>
<li>eventmachine</li>
<li>permessage_deflate</li>
<li>json</li>
<li>httparty</li>
<li>websocket-extensions</li>
<li>mysql</li>
</ul>

# Credit to <a href="https://github.com/bombergio">bombergio</a>
## I used his <a href="https://github.com/bombergio/3cx_wallboard_dashing">3cx_wallboard_dashing</a> as a basis for this.
