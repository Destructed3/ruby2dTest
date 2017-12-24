require 'ruby2d'

### Create the visible game
## Setup Window
set title:      "Pong2017"
set background: "red"
set width:      800
set height:     640

### Objects Logic
# GUI
class GUI
	attr_accessor :scored
	attr_accessor :info

	def initialize
		# GUI Objects
		@backg  = Rectangle.new(x: 0, y: 600, width: 800, height: 200, z: 0, color: 'white')
		@p1     = Text.new(x:  10, y: 610, text:             'Paddle 1', size: 20, font: "./assets/Bungee-Regular.ttf", z: 1, color: 'black')
		@p2     = Text.new(x: 610, y: 610, text:             'Paddle 2', size: 20, font: "./assets/Bungee-Regular.ttf", z: 1, color: 'black')
		@score  = Text.new(x:   0, y: 610, text:                  '0:0', size: 20, font: "./assets/Bungee-Regular.ttf", z: 1, color: 'black')
		@scored = Text.new(x:   0, y: 610, text:                     '', size: 40, font: "./assets/Bungee-Regular.ttf", z: 1, color: 'black')
		@info   = Text.new(x:   0, y: 580, text: 'Press Space to start', size: 20, font: "./assets/Bungee-Regular.ttf", z: 1, color: 'white')
		# Proper centering of Objects only possible after creation, since width attribute is needed for that
		@p2.x    = 800 - @p2.width - 10
		@score.x = 400 - @score.width/2
		@info.x  = 800/2 - @info.width/2
	end

	# Score update
	def show_scored(player)
		@scored.text = "#{player} scored!"
		@scored.x    = 800/2 - @scored.width/2
		@scored.y    = 600/2 - @scored.height/2
	end

	def hide_scored
		@scored.text = ""
	end

	def update_score(p1, p2)
		@score.text = "#{p1} : #{p2}"
		@score.x    = 400 - @score.width/2
	end

	# Show additional Infos
	def show_info
		@info.text = "Press Space to start"
	end

	def hide_info
		@info.text = ""
	end
end

# Player
class Player
	attr_accessor :score
	attr_reader   :name

	def initialize(name, x, color)
		@name   = name
		@paddle = Rectangle.new(x:  x, y: 250, width: 30, height: 100, z: 1, color: color)
		@score  = 0
	end

	# Movement
	def moveUp
		@paddle.y -= 1 if @paddle.y > 0
	end

	def moveDown
		@paddle.y += 1 if self.bottom < 600
	end

	# Positioning / Coordinates
	def reset_position
		@paddle.y = 600/2 - @paddle.height
	end

	def top
		return @paddle.y
	end

	def right
		return @paddle.x + @paddle.width
	end

	def bottom
		return @paddle.y + @paddle.height
	end

	def left
		return @paddle.x
	end

	def parts
		parts = {
			:top    => @paddle.y + @paddle.height/3,
			:bottom => @paddle.y + 2*@paddle.height/3
		}
		return parts
	end

end

# Ball
class Ball

	attr_reader :x_speed
	attr_reader :y_speed

	def initialize
		@square   = Square.new(size: 16, color: 'black')
		@square.x = 800/2 - @square.size/2
		@square.y = 600/2 - @square.size/2
		@x_speed  = 0
		@y_speed  = 0
	end

	# Movement
	def start()
		if rand(2) == 1 then @x_speed = 2 else @x_speed = -2 end
		if rand(2) == 1 then @y_speed = rand(2) else @y_speed = rand(2) * -1 end
	end

	def move
		@square.x += @x_speed
		@square.y += @y_speed
	end

	def y_speed_change(change)
		@y_speed = determine_speed(@y_speed, change)
	end

	def x_speed_change(change)
		@x_speed = determine_speed(@x_speed, change)
	end

	def y_speed_reverse
		@y_speed = -@y_speed
	end

	def x_speed_reverse
		@x_speed = -@x_speed
	end

	# Positioning / Coordinates
	def reset_position()
		@square.x = 800/2 - @square.size/2
		@square.y = 600/2 - @square.size/2
	end

	def top
		return @square.y
	end

	def right
		return @square.x + @square.size
	end

	def bottom
		return @square.y + @square.size
	end

	def left
		return @square.x
	end

	def center
		center = {
			:y => @square.y + @square.size/2,
			:x => @square.x + @square.size/2	# this value is never needed and only there because otherwise it hurts my need for symmetry
		}
		return center
	end

	private

	# Helper that updates speed according to limits (defined in funciton)
	def determine_speed(speed, change)
		if speed + change < 0
			if speed + change > -3
				return speed += change
			else
				return speed = -2
			end
		else
			if speed + change < 3
				return speed += change
			else
				return speed = 2
			end
		end
	end

end

### Game Logic
## Objects & Vars
# Objects
$ball = Ball.new
$p1   = Player.new("Player 1",  20, 'white')
$p2   = Player.new("Player 2", 750, 'blue')
$gui  = GUI.new
# Game-State
$running = false

## Functions
# Check for collosions of the ball with a wall or a player
def check_collision_x
	if    $ball.left <= 0
		score($p2)								# Player 2 scores
	elsif $ball.left <= $p1.right && $ball.bottom > $p1.top && $ball.top < $p1.bottom
		change_direction_at($p1)	# Collision with Player 1
	elsif $ball.right >= $p2.left && $ball.bottom > $p2.top && $ball.top < $p2.bottom
		change_direction_at($p2)	# Collision with Player 2
	elsif $ball.right >= 800
		score($p1)								# Player 2 scores
	end

end

# Check for collisions of ball with wall
def check_collision_y
	if $ball.top <= 0 || $ball.bottom >= 600
	    $ball.y_speed_reverse
	end
end

# Change Ball direction after collision with player
=begin
	Rules for changes of y-axis speed
	1 if center of ball is above top of colliding player
		1.1 reverse y-axis speed if the ball was falling until now
		1.2 otherwise add -2 to y-axis speed
	2 if center of ball is in upper third of the paddle, add -1 to y-axis speed
	3 if center of ball is in lower third of the paddle, add  1 to y-axis speed
	4 if center of ball is below bottom of colliding player
		4.1 reverse y-axis speed if the ball was raising until now
		4.2 otherwise add  2 to y-axis speed
	5 if none of the former is true (the ball hit the middle), do nothing
=end
def change_direction_at(player)
	$ball.x_speed_reverse

	if    $ball.center[:y] <= player.top
		if $ball.y_speed > 0 then $ball.y_speed_reverse()
		else $ball.y_speed_change(-2) end

	elsif $ball.center[:y] <= player.parts[:top]
		$ball.y_speed_change(-1)

	elsif $ball.center[:y] >= player.parts[:bottom]
		$ball.y_speed_change(1)

	elsif $ball.center[:y] >= player.bottom
		if $ball.y_speed < 0 then $ball.y_speed_reverse
		else $ball.y_speed_change(2) end

	end

end

# Handle a player scoring
=begin
	1 set game state $running to 'false'
	2 add one point to scoring player
	3 update score in GUI
	4 show additionl infos in GUI (who scored, how to continue playing)
=end
def score(player)
	$running = false
	player.score += 1
	$gui.show_scored(player.name)
	$gui.show_info()
	$gui.update_score($p1.score, $p2.score)
end

# Start Game
=begin
	1 hide additional infos in GUI
	2 reset position of players
	3 reset position of ball
	4 give ball starting direction
	5 set game state $running to 'true'
=end
def startGame
	if !$running
		$gui.hide_info()
		$gui.hide_scored()
		$p1.reset_position()
		$p2.reset_position()
		$ball.reset_position()
		$ball.start()
		$running = true
	end
end

### Events
## Move player-paddles
on :key_held do |e|
	case e.key
	when "w"
		$p1.moveUp
	when "s"
		$p1.moveDown
	when "up"
		$p2.moveUp
	when "down"
		$p2.moveDown
	end
end

## Other Key-Events
on :key_down do |event|
	case event.key
	when 'escape'
		close
	when 'space'
		startGame()
	end
end

### Game loop
=begin
	1 if game-state $running is true,
	2 move the ball,
	3 then check if this led to any collisions
=end
update do
	if $running
		$ball.move()
		check_collision_y()
		check_collision_x()
	end
end

### Start the game
show
