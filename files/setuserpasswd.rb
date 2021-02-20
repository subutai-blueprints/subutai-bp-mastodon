#!/usr/bin/env ruby

require 'tempfile'

# See https://stackoverflow.com/questions/10313181/pass-ruby-script-file-to-rails-console/19748275
# See https://nsnw.ca/resetting-user-passwords-on-mastodon/

# First arg = username
# Second arg = password

# set to false in final bp
$debug_mode = true

def info(msg)
  STDOUT.puts "\e[33m#{msg}\e[0m"
end

def error(msg)
  STDOUT.puts "\e[31m#{msg}\e[0m"
end

def debug(msg)
  STDOUT.puts "\e[32m#{msg}\e[0m" if $debug_mode
end

if ARGV.length != 2
  error("Incorrect number of arguments: expecting username and password.")
  exit 1
end

temp = Tempfile.new
temp << "#!/usr/bin/env ruby\n"
temp << "\n"
temp << "account = Account.find_by(username: '#{ARGV[0]}')\n"
temp << "user = User.find_by(account: account)\n"
temp << "user.password = '#{ARGV[1]}'\n"
temp << "user.save!\n"
temp << "exit\n"
temp << "\n"
temp.flush

cmd = "rails r #{temp.path}"
info("Will exec '#{cmd}'")
debug("With contents:\n" + `cat #{temp.path}`)

`#{cmd}` unless $debug_mode

