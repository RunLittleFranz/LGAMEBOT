require_relative "PlayerSet"
class Player 

    attr_accessor :info
    attr_accessor :chat_id
    attr_accessor :message
    attr_accessor :player_set
    def initialize info, chat_id
        @info = info
        @chat_id = chat_id
    end

    def player_color 
        return "Rosso" if @player_set == PlayerSet.redPlayer
        return "Blu" if @player_set == PlayerSet.bluePlayer
    end

end