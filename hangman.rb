require 'json'

puts "Let the game begin. . . "

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
    @user_progress = user_guess
    @remaining_lives = remaining_lives
    @secrete_word = secrete_word
    @letters_guessed = letters_guessed
  end

  def set_up_game()
    @remaining_lives = 7 #starts with 7 lives
    words = Array.new()
    all_words = File.readlines('google-10000-english-no-swears.txt')
    all_words.each do |word|
      word_length = word.length - 1
      if word_length >= 5 && word_length <= 12
        puts word
        words.push(word)
      end
    end
    
    @secrete_word = all_words.sample
    puts @secrete_word
    @user_progress = Array.new(@secrete_word.length - 1, '_')
    p @user_progress
    playing = true 
    @letters_guessed = 0
  end
  
  def to_json
    JSON.dump ({
      :user_progress => @user_progress
      :remaining_lives => @remaining_lives,
      :secrete_word => @secrete_word
      :letters_guessed => @letters_guessed
    })
  end

  def self.from_json(string)
    data = JSON.load string
    self.new(data['user_progress'], data['remaining_lives'], data['secrete_word'], data['letters_guessed'])
  end

  while playing
    puts "you can save the game state by entering 'save'"
    puts "you currently have #{@remaining_lives} lives!"
    puts "type a letter: "
    user_guess = gets.gsub("\n",'')
  
    if !is_valid_user_input(user_guess)
      puts "invalid input! Try again"
      next
    end
    user_guess.downcase
    
    if @secrete_word.include?(user_guess)
      @secrete_word.split("").each_with_index do | c, idx |
        if c == user_guess
          @user_progress[idx] = user_guess #reveal letter(s)
          @letters_guessed += 1
        end
      end
    else 
      @remaining_lives -= 1
    end
    
    p @user_progress
  
    if @remaining_lives == 0
      playing = false
    elsif @letters_guessed == @secrete_word.length - 1
      playing = false
      puts "Congrats! You win!"
    end
  end
end