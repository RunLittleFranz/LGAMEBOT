require_relative "PlayerSet"
class Player 

    attr_accessor :info
    attr_accessor :message
    attr_accessor :player_set
    def initialize info
        @info = info
    end

    def player_color 
        return "Rosso" if @player_set == PlayerSet.redPlayer
        return "Blu" if @player_set == PlayerSet.bluePlayer
    end

end