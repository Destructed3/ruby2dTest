require 'ruby2d'

# Game Window
set title:      "Draughts"
set background: "yellow"
set width:      512
set height:     512

# Map
=begin
1   Map-Grid 8x8 Felder
2   Felder
2.1 haben 2 mögliche Farben: schwarz : weiß
2.2 kennen ihre Nachbarn
2.3 wissen, ob sie besetzt sind
2.4 kennen eigene Koordinaten
3   Token
3.1 kennen das Feld auf dem sie sich befinden
3.2 können sich diagonal bewegen (links-oben/-unten, rechts-oben/-unten)
3.3 können andere Figuren schlagen
3.4 können aufgewertet werden, wenn sie das gegenüberliegende Ende des Spielfeldes erreichen
4   Könige (aufgewertete Token)
4.1 ???
5.  Spiel endet, sobald eine Seite keinen Stein mehr hat
=end

class Node
    attr_reader :neighbors
    attr_reader :coordinates

  def initialize(x_coordinate, y_coordinate)
    @neighbors   = Hash.new
    @coordinates = {
        :x => x_coordinate, 
        :y => y_coordinate,
    }
    @body        = addSquare()

    addNeighbors()
  end

  def isBlack?
    return (@coordinates[:x]+@coordinates[:y])%2 != 0
  end



  def addNeighbors()

    addTopNeighbors()    if @coordinates[:y] > 0
    addBottomNeighbors() if @coordinates[:y] < 7
    addLeftNeighbor()    if @coordinates[:x] > 0
    addRightNeighbor()   if @coordinates[:x] < 7

  end

    def placeToken(token)
        @token  = token if isBlack?
    end

    def highlight()
        @body.color = 'blue' if isBlack?
    end



    def resetColor()
        @body.color = getSquareColor()
    end

    def isHighlighted?()
        return @body.color === 'blue'
    end

  private

  def addTopNeighbors()
    @neighbors[:top]      = [@coordinates[:x],   @coordinates[:y]-1]
    @neighbors[:topLeft]  = [@coordinates[:x]-1, @coordinates[:y]-1] if @coordinates[:x] > 0
    @neighbors[:topRight] = [@coordinates[:x]+1, @coordinates[:y]-1] if @coordinates[:x] < 7
  end

  def addBottomNeighbors()
    @neighbors[:bottom]      = [@coordinates[:x],   @coordinates[:y]+1]    
    @neighbors[:bottomLeft]  = [@coordinates[:x]-1, @coordinates[:y]+1] if @coordinates[:x] > 0
    @neighbors[:bottomRight] = [@coordinates[:x]+1, @coordinates[:y]+1] if @coordinates[:x] < 7
  end

  def addLeftNeighbor()
    @neighbors[:left] = [@coordinates[:x]-1, @coordinates[:y]]
  end

  def addRightNeighbor()
    @neighbors[:right] = [@coordinates[:x]+1, @coordinates[:y]]
  end

  def addSquare()
    return Square.new(
      x:     @coordinates[:x] * 64,
      y:     @coordinates[:y] * 64,
      z:     1,
      size:  64,
      color: getSquareColor()
    )
  end

  def getSquareColor()
    return 'black' if isBlack?
    return 'white'
  end

end

class Token
    attr_accessor :x
    attr_accessor :y
    attr_reader   :player

    def initialize(x, y, player, color)        
        @x      = x
        @y      = y
        @player = player
        initBody(color)
    end

    private

    def initBody(color)
        @body   = Text.new(
            text:  "O", 
            size:  20, 
            font:  "./assets/Bungee-Regular.ttf", 
            color: color, 
            z:     3
        )
        centerBody()
    end

    def centerBody()
        @body.x = @x * 64 + 32 - @body.width/2
        @body.y = @y * 64 + 32 - @body.height/2
    end

end

class King < Token
end

def initMap()
    $map = Array.new
    fillMap()
    #connectNodes()
    placeToken_for("top")
    placeToken_for("bottom")
end

def fillMap()
    8.times do |x|
        $map[x] = Array.new
        8.times do |y|
            $map[x][y] = Node.new(x, y)
        end
    end
end

# def connectNodes()
#     $map.each do |col|
#         col.each do |node|
#             node.addNeighbors()
#         end
#     end

# end

def placeToken_for(position)
    #args = getArgs_token(position)
    if position === "top"
        player = "Player 1"
        color  = "green"
        row    = 0
    else
        player = "Player 2"
        color  = "red"
        row    = 5
    end

    12.times do
        8.times do |x|
            row.upto(row + 2) do |y|
                $map[x][y].placeToken(Token.new(x, y, player, color)) if $map[x][y].isBlack?
            end
        end
    end
end

on :key_down do |e|
  case(e.key)
  when 'escape'
    close
  end
end

on :mouse_move do |e|
    $mouse.highlightNode(e.x, e.y)
end

class Mouse
    def highlightNode(x, y)
        x_coordinate = (x / 64).floor
        y_coordinate = (y / 64).floor
        if(!$map[x_coordinate][y_coordinate].isHighlighted? && $map[x_coordinate][y_coordinate] != $highlighted)
            $highlighted.resetColor() if $highlighted != nil
            $highlighted = $map[x_coordinate][y_coordinate]
            $highlighted.highlight()
        end
    end

    def highlightMove(x_origin, y_origin)
    end
end

def initMouse()
    $mouse = Mouse.new()
end

# Start Game
initMap()
initMouse()

show
