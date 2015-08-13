#!/usr/bin/expect -f

set password[lindex $argv 1]
spawn passwd
expect "password:"
send "$password\r"
expect "password:"
send "$password\r"
expect eof
