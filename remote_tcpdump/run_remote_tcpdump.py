#!/usr/bin/python

import sys
import ssh
from optparse import OptionParser

hostname = '192.168.33.20'
username = 'root'
password = 'password'
port = 22

def options_parse(o, args):
    if o.directory != None:
        directory = o.directory
    if o.confirm:
        confirm = True
    if o.remote_host:
        remote_host = o.remote_host
    if o.username:
        username = o.username
    if o.password:
        password = o.password
    if o.port:
        port = o.port
    if o.interface:
        interface = o.interface
    if o.filename:
        filename = o.filename


client = ssh.SSHClient()
client.load_system_host_keys()
#client.connect(hostname, port=port, username=username, password=password)

#stdin, stdout, stderr = client.exec_command('tcpdump')


#for l in stdout.read().split('\n'):
#    print l
#client.close()

if __name__ == '__main__':
    parser = OptionParser()
    parser.add_option('-d', '--directory', dest='directory',
                        help='destination directory')    
    parser.add_option('-c', '--confirm', dest='confirm', action='store_true',
                        default=False, help='confirm each move')
    parser.add_option('-r', '--remote-host', dest='ipaddr',
                        help='ipaddress of remote host')
    parser.add_option('-u', '--usermane', dest='username',
                        help='username of remote host')
    parser.add_option('-s', '--password', dest='password',
                        help='password of remote host')
    parser.add_option('-p', '--port', dest='port',
                        help='ssh port number of remote host')    
    parser.add_option('-i', '--interface', dest='interface',
                        help='tcpdump interface of remote host')
    parser.add_option('-w', '--filename', dest='filename',
                        help='filename of tcpdump result')
    options, args = parser.parse_args(sys.argv[1:])
