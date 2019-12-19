require_relative "PlayerSet"
class GameBoardKeys

    attr_accessor :value, :text, :player_set
    def initialize value, text, player_set
        @value = value
        @text = text
        @player_set = player_set
    end

    def self.blankKey
        return GameBoardKeys.new(0, "⚪️", PlayerSet.noPlayer)
    end

    def self.pennyKey
        return GameBoardKeys.new(1, "⚫️", PlayerSet.shared)
    end

    def self.editPennyKey
        return GameBoardKeys.new(2, "🔆", PlayerSet.shared)
    end

    def self.redFinalKey
        return GameBoardKeys.new(3, "🔴", PlayerSet.redPlayer)
    end

    def self.redEditKey
        return GameBoardKeys.new(4, "🔶", PlayerSet.redPlayer)
    end

    def self.blueFinalKey
        return GameBoardKeys.new(5, "🔵", PlayerSet.bluePlayer)
    end

    def self.blueEditKey
        return GameBoardKeys.new(6, "🔷", PlayerSet.bluePlayer)
    end



end