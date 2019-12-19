require_relative "GameBoardKeys"
require "telegram/bot/api"
class GameBoard

    @final_matrix 
    @edit_matrix
    @is_edit
    def initialize 
        @final_matrix = default_matrix
        @edit_matrix = default_matrix
        @is_edit = true
    end

    def is_edit 
        @is_edit 
    end

    def is_edit=(v)
        @is_edit=v
    end


    def default_matrix 
        m = [
        [GameBoardKeys.pennyKey, GameBoardKeys.blueFinalKey, GameBoardKeys.blueFinalKey, GameBoardKeys.blankKey],
        [GameBoardKeys.blankKey, GameBoardKeys.redFinalKey, GameBoardKeys.blueFinalKey, GameBoardKeys.blankKey],
        [GameBoardKeys.blankKey, GameBoardKeys.redFinalKey, GameBoardKeys.blueFinalKey, GameBoardKeys.blankKey],
        [GameBoardKeys.blankKey, GameBoardKeys.redFinalKey, GameBoardKeys.redFinalKey, GameBoardKeys.pennyKey]
        ]
        return m
    end

    def key(x, y)
        @edit_matrix[x][y]
    end

    def edit_key(x, y, val)   
        @edit_matrix[x][y] = val

        @is_edit = true
    end

    def save_board player_set, penny_check = false
        puts "ALLORA"
        editKey = (PlayerSet.redPlayer == player_set) ? GameBoardKeys.redEditKey : GameBoardKeys.blueEditKey
        finalKey = (PlayerSet.redPlayer == player_set) ? GameBoardKeys.redFinalKey : GameBoardKeys.blueFinalKey
        
            #final => blank, edit => final 
        @edit_matrix.each.with_index do |sub_m, y|    
            sub_m.each.with_index do |elem, x|
                print elem.value == editKey.value 
                if elem.value == finalKey.value && !penny_check
                    @edit_matrix[y][x] = GameBoardKeys.blankKey
                elsif elem.value == editKey.value  && !penny_check
                    @edit_matrix[y][x] = finalKey
                elsif elem.value == GameBoardKeys.editPennyKey.value  && penny_check
                    @edit_matrix[y][x] = GameBoardKeys.blankKey
                end                    
            end
            puts "\n"
        end
        @final_matrix = Marshal.load(Marshal.dump(@edit_matrix))
    end

    def undo_board 

        @edit_matrix = Marshal.load(Marshal.dump(@final_matrix))
    end

    def checkEdit player_set
        editKey = (PlayerSet.redPlayer == player_set) ? GameBoardKeys.redEditKey : GameBoardKeys.blueEditKey
        f = check_validity(@edit_matrix, editKey)
        puts f
        if !f       
            undo_board
            return false 
        else 
            save_board player_set
            puts "DANKE"
            return true
        end
    end

    def checkFinal player_set
        editKey = (PlayerSet.redPlayer == player_set) ? GameBoardKeys.redFinalKey : GameBoardKeys.blueFinalKey
        f = check_validity(@edit_matrix, editKey)
        puts f
        if !f       
            undo_board
            return false 
        else 
            save_board player_set
            return true
        end
    end

    def print_matrix m 
        m.each do |sub_m|
            sub_m.each do |ele|
                print ele.text
            end 
            puts "\n"
        end

    end

    def sub_matrix(matrix, v)
        xsub = []
        ysub = []
        matrix.each do |sub_m|
            count = 0
            sub_m.each.with_index do |elem, i|
                xsub[i] = 0 if xsub[i].nil?
                if elem.value == v.value 
                    count += 1
                    xsub[i] += 1
                end
            end
            ysub << count
        end
        return [xsub, ysub]
    end
    
    def check_validity(matrix, v) # matrice di ingresso e valore da controllare => ritorna true se il valore compone una forma a L 31/13 112/211
        sub_m = sub_matrix(matrix, v)
        flag = true
        comp31 = false
        comp211 = false
        sub_m.each do |ssm|
            if (ssm - [0]) == [3,1] || (ssm - [0]).reverse == [3,1] 
                comp31 = !(ssm.join =~ /13|31|112|211/).nil?       
            elsif (ssm - [0]) == [2,1,1] || (ssm - [0]).reverse == [2, 1, 1]
                comp211 = !(ssm.join =~ /13|31|112|211/).nil?
            else 
                flag = false
            end
        end
        return flag && comp31 && comp211
    end

    def push_change

    end

    def matrix_to_keyboard flag = true, can_pass = true
        @is_edit = false
        m = (flag) ? @final_matrix : @edit_matrix
        kb = []
        m.each.with_index do |sub_m, y|
            sub_array = []
            sub_m.each.with_index do |elem, x|
                sub_array << Telegram::Bot::Types::InlineKeyboardButton.new(text: elem.text, callback_data: "#{y}#{x}")
            end
            kb << sub_array
        end
        pass_button = (!can_pass) ? Telegram::Bot::Types::InlineKeyboardButton.new(text: "Muovi Penny", callback_data: "penny") : Telegram::Bot::Types::InlineKeyboardButton.new(text: "Passa", callback_data: "pass")
        kb << [ Telegram::Bot::Types::InlineKeyboardButton.new(text: "Indietro", callback_data: "back"), pass_button]
        return Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
    end
end