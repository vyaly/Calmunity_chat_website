require 'eventmachine'
class ClientEvent
    @@searching = []
    def findMatch(usr)
        unless @@searching.length == 0
            return @@searching[0]
        end
        return nil
    end
    def incoming(message, callback)
        puts message
        puts ''
        if message['channel'] == '/meta/disconnect' || message['channel'] == '/meta/unsubscribe'
            # remove the ID from array
            idToRemove = message['clientId']
            client.publish('/' + idToRemove, "The other person has left")
            @@searching.each do |val|
                if val.id == idToRemove
                    @@searching.delete(val)
                end
            end
        elsif message['channel'] == '/meta/subscribe'
            # check if they subscribed to searching, if so get id, create a new Search object and store it in array
            unless message['subscription'] == nil || message['subscription'][0..7] == '/search/'
                return callback.call(message)
            end
            newSearch = Search.new(message['clientId'], message['subscription'])
            match = findMatch(newSearch)
            if match != nil
                @@searching.delete(newSearch)
                @@searching.delete(match) 
                EM.run{ 
                    client = Faye::Client.new('http://localhost:9292/faye')
                    id1 = '/' + match.id
                    id2 = '/' + newSearch.id
                    generatedRoom = id1 + '/' + id2
                    client.publish(newSearch.roomId, {recv: id1, send: id2})
                    client.publish(match.roomId, {send: id1, recv: id2})
                }
            else
                @@searching[@@searching.length] = newSearch
            end 
        end
        return callback.call(message)
    end
end

class Search
    def initialize(clientId, searchRoomId)
        @id = clientId
        @roomId = searchRoomId
    end

    def id
        return @id
    end

    def roomId
        return @roomId
    end
end