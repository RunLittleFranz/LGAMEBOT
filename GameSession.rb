require_relative "GameBoard"
require_relative "GameBoardKeys"
class GameSession 
    attr_accessor :id
    @players
    @gameBoard
    @bot
    @turn 
    @can_pass = false
    @is_penny_selected = false
    @is_penny_positioned = false
    @is_blank_selected = false
    def initialize bot, players, id
        @id = id
        @players = players
        @bot = bot
        @gameBoard = GameBoard.new  
        @can_pass = false
        @is_penny_selected = false
        @is_blank_selected = false
        @is_penny_positioned = false
    end

    
    def start 
        @players.each.with_index do |plr, i|
            @bot.api.send_message(chat_id: plr.chat_id, text: "INIZIO PARTITA: #{@players[0].info.first_name} VS #{@players[1].info.first_name}")
            @players[i].message = @bot.api.send_message(chat_id: plr.chat_id, text: "Game Loading...")
        end
        @players[0].player_set = PlayerSet.redPlayer
        @players[1].player_set = PlayerSet.bluePlayer
        @turn = 0
        showGameBoard

    end



    def showGameBoard
        if @gameBoard.is_edit 

            kb = @gameBoard.matrix_to_keyboard(true, @can_pass)
        #puts @players[0].message.inspect
            @players.each do |plr|
                @bot.api.edit_message_text(chat_id: plr.chat_id, 
                message_id: plr.message["result"]["message_id"],
                text: "Turno di #{player_turn.info.first_name} - Colore: #{player_turn.player_color}",
             reply_markup: kb
             )
            end
        end 
    end

    def showEditGameBoard error_text = "", flag = true 
        if @gameBoard.is_edit 
        kb = @gameBoard.matrix_to_keyboard(flag, @can_pass)
        #puts @players[0].message.inspect
            @bot.api.edit_message_text(chat_id: player_turn.chat_id, 
            message_id: player_turn.message["result"]["message_id"],
            text: "Turno di #{player_turn.info.first_name} - Colore: #{player_turn.player_color}\n#{error_text}",
            reply_markup: kb
            )
        end
    end

    def player_turn 
        @players[@turn]
    end

    def players 
        @players
    end

    def userAction player_id, code
        plr = player_by_id player_id
        puts plr.nil? || player_turn.info.id != plr.info.id
        return if plr.nil? || player_turn.info.id != plr.info.id
        if code == "pass"
            
            if @is_penny_selected
                showEditGameBoard "Muovi Il Penny!", false
            else 
                pass 
                showGameBoard
                @can_pass = false
            end
        elsif code == "penny"
            if !@is_blank_selected
                @gameBoard.undo_board
                showEditGameBoard "Non puoi fare questa mossa!"
            else 
                if !@gameBoard.checkEdit(player_turn.player_set)
                    puts "HEY BRO"
                    showEditGameBoard "Mossa non valida!"
                
                #@gameBoard.is_edit = true
                else 
                    @can_pass = true 
                    showEditGameBoard "Muovi il Penny", false
                    @gameBoard.is_edit = true
                end
            end
        elsif code == "back"
            back
        else 
            keys = code.split("").map! { |x| x.to_i }
            key = @gameBoard.key(keys[0], keys[1])
            editKey = (PlayerSet.redPlayer == player_turn.player_set) ? GameBoardKeys.redEditKey : GameBoardKeys.blueEditKey
            
            if (key.player_set == player_turn.player_set || key.player_set == PlayerSet.noPlayer) && !@can_pass
                return if key.value == editKey.value
                @is_blank_selected = (!@is_blank_selected) ?  key.value == GameBoardKeys.blankKey.value : @is_blank_selected
                @gameBoard.edit_key(keys[0], keys[1], editKey)
                showEditGameBoard "", false
                @gameBoard.is_edit = true
            elsif key.value == GameBoardKeys.pennyKey.value && @can_pass && !@is_penny_selected && !@is_penny_positioned
                @gameBoard.edit_key(keys[0], keys[1], GameBoardKeys.editPennyKey)
                showEditGameBoard "", false
                @gameBoard.is_edit = true
                @is_penny_selected = true
            elsif (key.value == GameBoardKeys.blankKey.value || key.value == GameBoardKeys.editPennyKey.value) && @can_pass && @is_penny_selected && !@is_penny_positioned
                @gameBoard.edit_key(keys[0], keys[1], GameBoardKeys.pennyKey)
                showEditGameBoard "", false
                @gameBoard.is_edit = true
                @is_penny_selected = false
                @is_penny_positioned = true
            end
        end
    end
    
    def pass 
        @gameBoard.save_board(player_turn.player_set, true)
        @bot.api.send_message(chat_id: player_turn.chat_id, text: "Board: #{@gameBoard.matttrix} \nRank board: #{@gameBoard.rank}")
        puts @gameBoard.rank
        reset_flags
        #return false if !@gameBoard.checkEdit(player_turn.player_set) || !@gameBoard.checkFinal(player_turn.player_set)
        @turn = (@turn == 0) ? 1 : 0
    end

    def back 
        @gameBoard.undo_board
        showEditGameBoard ""
        reset_flags
    end

    def reset_flags
        @is_penny_selected = false
        @is_blank_selected = false
        @is_penny_positioned = false
    end

    def player_by_id id 
        @players.each do |plr|
            if plr.info.id == id
                return plr
            end
        end
    end
    
    def drop id
        plr_scemo = player_by_id id 
        #puts @players[0].message.inspect
            @players.each do |plr|
                @bot.api.edit_message_text(chat_id: plr.chat_id, 
                message_id: plr.message["result"]["message_id"],
                text: "#{plr_scemo.info.first_name} ha abbandonato la partita",
             )
            end
    end

    def players 
        @players 
    end

end