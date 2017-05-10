require 'yaml'

class Game

	def initialize(game_name, player_name)
		@game_name = game_name
		@player = Player.new(player_name)
		@wrong_guesses = -1
		@wrong_guess_display = []

	end

	def pick_word
		@word = ''
		dictionary = File.open("5desk.txt").readlines

		while @word.length < 5 || @word.length > 12
			@word = dictionary[rand(61406)]
		end

		@word.strip!.downcase!
		create_display(@word)
	end

	def create_display(word)
		@secret_display = []
		@public_display = []
		word.split('').each do |char|
			@secret_display << char
			@public_display << " "
		end
	end

	def show_display
		print @public_display
	end

	def change_display(guess)
		multi_char = @secret_display
		multi_index = []

		if @public_display.include?(guess) == false
			if @secret_display.count(guess) > 1 #if guess occurs multiple times in word...

				(@secret_display.count(guess)).times do #...then find index of each occurence...
					multi_index << multi_char.index(guess)
					multi_char[(@secret_display.index(guess))] = " "
				end

				multi_index.each do |index|
					@public_display[index] = guess #...and add all occurences to public display
			  end

			else
				index = @secret_display.index(guess)
				@public_display[index] = guess
			end
		end
	end

	def check_guess
		guess = @player.guess?

		if @word.include?(guess) == true
			change_display(guess)

		else
			@wrong_guesses += 1
			draw_hangman
			@wrong_guess_display << guess
		end

	end

	def draw_hangman
		@body_parts = ["head", "body", "right arm", 
			            "left arm", "right leg",
			          	"left leg"]
		@hangman = []
		@hangman << @body_parts[@wrong_guesses]
	end

	def hangman?
		return @hangman
	end

	def winner?
		if @public_display == @word.split('')
			return true
		end
	end

	def display_wrong_guesses
		print @wrong_guess_display
	end

	def player?
		return @player
	end

	def wrong_guesses?
		return @wrong_guesses
	end

end

class Player

	def initialize(name)
		@name = name
	end

	def guess(input)
		@guess = input.downcase
	end

	def guess?
		return @guess
	end

end

puts "Would you like to start a new game or load a game?"
puts"\n"
choice = gets.chomp.downcase

if choice == "load" || choice == "load game"
	my_game = YAML.load File.read('my_yaml.yaml')
	player = my_game.player?
else
	my_game = Game.new("My game", "John")
	my_game.pick_word
	player = my_game.player?
end

winner = false
wrong_guesses = my_game.wrong_guesses?

while wrong_guesses < 5 && winner == false

	puts "Would you like to guess or save?"
	puts "\n"
	choice = gets.chomp.downcase
	puts "\n"

	if choice == "save"
		serialized_object = YAML::dump(my_game)
		f = File.new("my_yaml.yaml", "w")
		f.puts serialized_object
		f.close

	elsif choice == "guess"
		my_game.show_display
		puts "\n\n"
		guess = player.guess(gets.chomp)

		while guess.class != String || guess.length > 1 || guess == ""
			puts "Your input was not recognized!"
			guess = player.guess(gets.chomp)
		end

		my_game.check_guess

		if my_game.winner?
			my_game.show_display
			puts "\n"
			puts "You won!"
			winner = true
		end
	
		wrong_guesses = my_game.wrong_guesses?

		if wrong_guesses > -1
			print my_game.hangman?
			puts "\n"
			my_game.display_wrong_guesses
			print "\n"
		end

	else
		puts "Input not understood!"
		puts "\n"
	end

end

if winner == false
	puts "\n"
	puts "You lost!"
end