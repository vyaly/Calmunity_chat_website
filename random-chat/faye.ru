require 'faye'

load 'faye/client_event.rb'

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
faye_server.add_extension(ClientEvent.new)

run faye_server
