require 'json'

puts "Let the game begin. . . "
puts "you can save the game state by entering 'save'"
puts "you can load the game you saved by typing 'load'"

def letter?(lookAhead)
  lookAhead.match?(/[[:alpha:]]/)
end

def is_valid_user_input(guess) 
  if (guess.length != 1 || !letter?(guess))
    return false
  end
  true
end

class Game
  def initialize(user_progress, remaining_lives, secrete_word, letters_guessed) 
    @user_progress = user_progress
    @remaining_lives = remaining_lives
    @secrete_word = secrete_word
    @letters_guessed = letters_guessed
  end

  public
  def set_up_game()
    @remaining_lives = 7 #starts with 7 lives
    words = Array.new()
    all_words = File.readlines('google-10000-english-no-swears.txt')
    all_words.each do |word|
      word_length = word.length - 1
      if word_length >= 5 && word_length <= 12
        words.push(word)
      end
    end
    
    @secrete_word = words.sample
    @user_progress = Array.new(@secrete_word.length - 1, '_')
  end
  
  def to_json
    JSON.dump ({
        :user_progress => @user_progress,
        :remaining_lives => @remaining_lives,
        :secrete_word => @secrete_word,
        :letters_guessed => @letters_guessed
    })
  end

  def self.from_json()
    file = File.read('./saved_game.json')
    data = JSON.parse(file)
    self.new(data["user_progress"], data["remaining_lives"], data["secrete_word"], data["letters_guessed"])
  end

  def play()
    playing = true
    while playing
      p @user_progress
      puts "you currently have #{@remaining_lives} lives!"
      puts "type a letter: "
      user_guess = gets.gsub("\n",'')
      game_saved_or_loaded = false

      #-----------------------------------------------------------
      # save/load game & valid input checker
      if user_guess == "save" 
        game_saved_or_loaded = true
        File.open("./saved_game.json","w") do |f|
          f.write(to_json())
        end
        puts "progress saved!"
      elsif user_guess == "load"
        if File.exists?("./saved_game.json")
          playing = false #quit current game and load new one
          puts "game loaded!"
          break
        else 
          puts "you didn't save any games. . . "
        end
      elsif !is_valid_user_input(user_guess)
        puts "invalid input! Try again"
        next
      end

      #----------------------------------------------------------
      # response to user guess
      user_guess.downcase
      
      if @secrete_word.include?(user_guess)
        @secrete_word.split("").each_with_index do | c, idx |
          if c == user_guess
            @user_progress[idx] = user_guess #reveal letter(s)
            @letters_guessed += 1
          end
        end
      elsif !game_saved_or_loaded
        @remaining_lives -= 1
      end
    
      if @remaining_lives == 0
        playing = false
      elsif @letters_guessed == @secrete_word.length - 1
        playing = false
        p @user_progress
        puts "Congrats! You win!"
      end
    end
  end
end

game = Game.new(Array.new(), 7, '', 0)
game.set_up_game()
game.play()

game = Game.from_json()
game.play()