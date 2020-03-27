require 'telegram/bot'
require_relative "Player"
require_relative "GameEngine"
require_relative "GameSession"
token = '1039539401:AAH2OQbIwYeW9b7j0mEKXDwgSwk8ah5fe7g'
gameEngine = nil 
pending_list = []

Telegram::Bot::Client.run(token) do |bot|
    gameEngine = GameEngine.new bot
    bot.listen do |message|

    if message.class == Telegram::Bot::Types::CallbackQuery
      # Here you can handle your callbacks from inline buttons
      if message.data
        gameEngine.parse message
      end
    elsif message.class == Telegram::Bot::Types::Message
      #puts "#{message.chat.id} \n #{message.from.id}"
      puts message.text
      if message.text =~ /^\/start/
        bot.api.send_message(chat_id: message.chat.id, text: "Benvenuto #{message.from.first_name}!\nPremi /newgame per iniziare a giocare contro altri giocatori online!")
      elsif message.text =~ /^\/newgame/
        p = Player.new(message.from, message.chat.id)
        #bot.api.send_message(chat_id: message.from.id, text: "In cerca di altri giocatori...")
        flag = gameEngine.matchMaker << p 
        if flag == MatchMakerError.isAlreadyPending 
          bot.api.send_message(chat_id: message.chat.id, text: "Sei già in cerca di una partita!")
        elsif flag == MatchMakerError.isAlreadyPlaying 
          bot.api.send_message(chat_id: message.chat.id, text: "Sei già in una partita!")
        end
      elsif message.text =~ /^\/info/
        bot.api.send_message(chat_id: message.chat.id, text: "Per le regole del gioco: https://it.wikipedia.org/wiki/L_game\nBot sviluppato da @runlittlefranz")
      elsif message.text =~ /^\/players_pending/ 
        bot.api.send_message(chat_id: message.chat.id, text: gameEngine.matchMaker.pending_list_str.inspect)
      elsif message.text =~ /^\/leave/
        gameEngine.killSession message
        puts gameEngine.matchMaker.playing_list.inspect
      end
    end
   #🔸🔸🔸🔸🔹🔹🔹🔹⚫️⚫️▫️▫️▫️▫️ 

    end
end