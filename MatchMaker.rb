class MatchMaker 

    @pending_list = []
    @playing_list = []
    @gameSessions = [] 
    @bot = nil
    
    
    def initialize bot
        @pending_list = []
        @playing_list = []
        @gameSessions = []
        @bot = bot
    end

    def <<(player)
        if isPending(player)
           return MatchMakerError.isAlreadyPending
        end 

        if isPlaying(player)
            return MatchMakerError.isAlreadyPlaying
        end

        @pending_list << player
        @bot.api.send_message(chat_id: player.info.id, text: "In cerca di una partita...")
        tryToMatch
    end

    def isPending player 
        @pending_list.each do |pnd_plr|
            if pnd_plr.info.id == player.info.id
                return true
            end
        end
        return false
    end 

    def isPlaying player 
        @playing_list.each do |pln_plr|
            if pln_plr.info.id == player.info.id
                return true
            end
        end
        return false
    end
    ###############################
    def pending_list_str
        return @pending_list.map { |plr| plr.info.first_name}
    end

    def pending_list
        @pending_list
    end

    def pending_list=(new_list)
       @pending_list = new_list
    end 

    def playing_list
        @playing_list
    end       

    def playing_list=(new_list)
        @playing_list = new_list
    end 
    ########################
    @engine = nil
    @func = nil
    def onMatchCreatedEventHandler engine, func 
        @engine = engine 
        @func = func        
    end

    def onMatchCreated players 
        @engine.method(@func).call(players)
    end


    private 
    def tryToMatch 
        if @pending_list.length >= 2
            players = @pending_list.reverse!.pop(2)
            @pending_list.reverse!
            players.each do |plr|
                @playing_list << plr
            end
            onMatchCreated players
        end
    end

end

class MatchMakerError

    def self.isAlreadyPending 
        return :isAlreadyPending
    end

    def self.isAlreadyPlaying 
        return :isAlreadyPlaying
    end 

end