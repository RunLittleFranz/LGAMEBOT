
require_relative "MatchMaker"
require_relative "GameSession"
class GameEngine
    @id_counter
    @bot = nil
    @matchMaker = nil
    @gameSessions
    def initialize bot 
        @id_counter = 0
        @bot = bot
        @matchMaker = MatchMaker.new bot
        @gameSessions = []
        setup
    end 

    def setup 
        @matchMaker.onMatchCreatedEventHandler(self, :matchCreated) 
    end

    def matchMaker 
        @matchMaker
    end

    def matchCreated players
        gameSession = GameSession.new(@bot, players, @id_counter)
        @id_counter += 1 
        gameSession.start
        @gameSessions << gameSession
    end 

    def parse message
        #cerca la gamesession con quel giocatore 
        #e manda le azioni relative alla gamesession che gestisce le evoluzioni della board
        currentGameSession = nil
        @gameSessions.each do |gs|
            gs.players.each do |plr|
                if plr.info.id == message.from.id
                    currentGameSession = gs 
                    break 
                end
            end
        end
        return if currentGameSession.nil?
        currentGameSession.userAction message.from.id, message.data
    end

    def killSession message
        puts message.from.id
        currentGameSession = nil
        @gameSessions.each do |gs|
            gs.players.each do |plr|
                if plr.info.id == message.from.id
                    currentGameSession = gs 
                    break 
                end
            end
        end
        puts "TEST #{currentGameSession}"
        return if currentGameSession.nil?
        puts currentGameSession.id
        currentGameSession.drop message.from.id
        
        deleteSession currentGameSession
    end

    def deleteSession gs
        id = gs.id 
        freePlayers gs
        new_gamesessions = []
        @gameSessions.each do |gms|
            if gms.id != id
                new_gamesessions << gms
            end
        end
        @gameSessions = new_gamesessions.dup
        puts @gameSessions.inspect
    end

    def freePlayers gs
        puts "OK"
        new_playing_list = []
        plrs = gs.players 
        @matchMaker.playing_list.each do |plr|
            puts plr.info.id != plrs[0].info.id || plr.info.id != plrs[1].info.id
            if plr.info.id != plrs[0].info.id && plr.info.id != plrs[1].info.id
                new_playing_list << plr 
            end
        end
        puts new_playing_list.dup.inspect
        @matchMaker.playing_list = new_playing_list.dup
        puts @matchMaker.playing_list.inspect
    end
    
end