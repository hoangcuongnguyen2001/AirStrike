require 'gosu'


#Reference: This program is based on ideas from the book Learn Game Programming with Ruby, Mark Sobkowicz, 
#chapter 4, 5 and 6.

SCREEN_WIDTH = 900 
SCREEN_HEIGHT = 750 
ACCELERATION = 3
ROTATION = 3
FRICTION = 0.9


#set up player's aircraft
class Player 
    attr_accessor :x, :y, :angle, :image, :velocity_x, :velocity_y, :radius, :window
   
    def initialize(window)
       @x = 450 
       @y = 600
       @angle = 0
       @image = Gosu::Image.new('images/player.png', :tileable => true)
       @velocity_x = 3
       @velocity_y = 3
       @radius = 40
       @window = window
    end 
end
    
    def accelerate player
      player.velocity_x += Gosu.offset_x(player.angle, ACCELERATION)
      player.velocity_y += Gosu.offset_y(player.angle, ACCELERATION)
    end 
  
    def turn_right player
      player.angle += ROTATION
    end
  
    def turn_left player
      player.angle -= ROTATION
    end
  
  
    def move_player player
      player.x += player.velocity_x 
      player.y += player.velocity_y 
      player.velocity_x *= FRICTION
      player.velocity_y *= FRICTION
      if player.x > SCREEN_WIDTH - player.radius
        player.velocity_x = 0
        player.x = SCREEN_WIDTH - player.radius 
      end
      if player.x < player.radius 
        player.velocity_x = 0
        player.x = player.radius 
      end
      if player.y > SCREEN_HEIGHT - player.radius 
        player.velocity_y = 0
        player.y = SCREEN_HEIGHT - player.radius
      end
      if player.y < player.radius 
        player.velocity_y = 0
        player.y = player.radius 
      end
    end
  
    def return_player player
      player.velocity_x -= Gosu.offset_x(player.angle, ACCELERATION)
      player.velocity_y -= Gosu.offset_y(player.angle, ACCELERATION)
    end
  
    def draw_player player
      player.image.draw_rot(player.x, player.y, 1, player.angle)
    end 

  
#set up enemies' aircrafts
  class Enemy  
    attr_accessor :x, :y, :angle, :radius, :image, :speed
    def initialize(window) 
      @radius = 25 
      @x = rand(window.width - 2 * @radius) + @radius 
      @y = 0 
      @angle = 0
      @image = Gosu::Image.new('images/enemy.png', :tileable => true) 
      @speed = rand(1..3)
    end
  end
      
    def move_enemy enemy
       enemy.y += enemy.speed
    end 
  
    def draw_enemy enemy
      enemy.image.draw_rot(enemy.x - enemy.radius, enemy.y - enemy.radius, 1, enemy.angle)
    end 
 
  
  
#set up missiles shot by player 
  class Friend_Missile
    attr_accessor :x, :y, :direction, :image, :radius, :window
     def initialize(window, x, y, angle) 
      @x = x 
      @y = y
      @direction = angle 
      @image = Gosu::Image.new('images/missile.png', :tileable => true) 
      @radius = 20
      @window = window
     end

    def onscreen? 
      right = @window.width + @radius 
      left = -@radius 
      top = -@radius
      bottom = @window.height + @radius
      @x > left and @x < right and @y > top and @y < bottom
    end
  end
  
    def move_friend_missile friend_missile
      friend_missile.x += Gosu.offset_x(friend_missile.direction, 10)
      friend_missile.y += Gosu.offset_y(friend_missile.direction, 10)
    end
  
  
    def draw_friend_missile friend_missile
      friend_missile.image.draw_rot(friend_missile.x - friend_missile.radius, friend_missile.y - friend_missile.radius, 1, friend_missile.direction)
    end 
 
  
  #set up explosions when enemy aircrafts are shot down
  class Explosion 
    attr_accessor :x, :y, :radius, :images, :image_index, :finished
    def initialize(window, x, y)
      @x = x 
      @y = y 
      @radius = 40
      @images = Gosu::Image.load_tiles('images/explosions.png',125,125) 
      @image_index = 0 
      @finished = false   
    end
  end
     
  
    def draw_explosion explosion
      if explosion.image_index < explosion.images.count 
        explosion.images[explosion.image_index].draw(explosion.x - explosion.radius, explosion.y - explosion.radius, 2) 
        explosion.image_index += 1 
      else
        @finished = true 
      end 
    end 
 

  #creating credits for video and images.
  class Credit 
   
    attr_accessor :x, :y, :text, :font
    def initialize(window, text, x, y) 
      @x = x 
      @y = @initial_y = y 
      @text = text 
      @font = Gosu::Font.new(24) 
    end 
  end

    def move_credit credit
      credit.y -= 1
    end

    def draw_credit credit
        credit.font.draw(credit.text, credit.x, credit.y, 1) 
    end

    def reset_credit credit
        credit.y = @initial_y 
    end
  
    

 #############################################################


 # main class of the game
class AirStrike < Gosu::Window 
    ENEMY_FREQUENCY = 0.01
    MAX_ENEMIES = 100
    def initialize
       super(SCREEN_WIDTH, SCREEN_HEIGHT) 
       self.caption = "Air Strike"
       @background_image = Gosu::Image.new('images/starting_image.png') 
       @scene = :start 
       @start_music = Gosu::Song.new('audio/TheDescent.wav') 
       @start_music.play(true)
       @locs = [60,60]
    end 

    def draw 
        case @scene 
        when :start
             draw_start
        when :game 
             draw_game
        when :end 
             draw_end 
        end 
    end 

    def draw_start
        @background_image.draw(0,0,0)
    end
    
   

    def update 
      case @scene
       when :game 
        update_game 
       when :end 
        update_end 
      end 
    end 

    def button_down(id) 
      case @scene 
      when :start
        button_down_start(id)
      when :game
        button_down_game(id)
      when :end 
        button_down_end(id) 
      end 
    end
     
#This part is for creating button for starting game.
    def needs_cursor?; true; end

    def area_clicked(mouse_x, mouse_y)
      if ((mouse_x > 150 && mouse_x < 750) && (mouse_y > 550 && mouse_y < 660))
        initialize_game
      end
    end

    def button_down_start(id)
      case id
      when Gosu::MsLeft
       @locs = [mouse_x, mouse_y]
       area_clicked(mouse_x, mouse_y)
      end
    end


    def initialize_game 
      @background_game = Gosu::Image.new("images/background.png", :tileable => true)
      @player = Player.new(self) 
      @enemies = [] 
      @missiles = [] 
      @explosions = [] 
      @scene = :game 
      @enemies_appeared = 0
      @enemies_destroyed = 0
      @game_music = Gosu::Song.new('audio/Hitman.wav')
      @game_music.play(true)
      @explosion_sound = Gosu::Sample.new("audio/explosion.wav")
      @shooting_sound = Gosu::Sample.new("audio/shoot.wav")
      @alert_sound = Gosu::Sample.new("audio/alertsound.wav")
      @font = Gosu::Font.new(30)
      @news = "Enemies appeared: "
      @news_2 = "Enemies destroyed: "
    end 


    def update_game
     turn_left @player if button_down?(Gosu::KbLeft) 
     turn_right @player if button_down?(Gosu::KbRight)
     accelerate @player  if button_down?(Gosu::KbUp)
     return_player @player if button_down?(Gosu::KbDown)
     move_player @player
      if rand < ENEMY_FREQUENCY
        @enemies.push Enemy.new(self)
        @enemies_appeared += 1
      end
      @enemies.each do |enemy|
        move_enemy enemy
      end
      @missiles.each do |friend_missile|
       move_friend_missile friend_missile
      end

      #This part is for eliminating enemies when firing missiles.
      @enemies.dup.each do |enemy|
        @missiles.dup.each do |friend_missile|
           distance = Gosu.distance(enemy.x, enemy.y, friend_missile.x, friend_missile.y) 
           if distance < enemy.radius + friend_missile.radius 
            @enemies.delete enemy
            @missiles.delete friend_missile
            @explosions.push Explosion.new(self, enemy.x, enemy.y)
            @explosion_sound.play
            @enemies_destroyed += 1
           end
        end
      end

  
      #This part ends the game when player hits enemies' aircrafts.
      @enemies.dup.each do |enemy|
        distance = Gosu.distance(enemy.x, enemy.y, @player.x, @player.y)
        if distance < 2.5 * (enemy.radius + @player.radius)
          @alert_sound.play(0.5)
        end
        if distance < enemy.radius + @player.radius
          initialize_end(:hit_by_enemy)
        end
      end
     
      #alert player when enemy planes are near the end of the screen.
      @enemies.dup.each do |enemy|
        distance =  SCREEN_HEIGHT - enemy.y 
        if distance < 200
           @alert_sound.play(0.5)
        end
      end

      @explosions.dup.each do |explosion|
        @explosions.delete explosion if explosion.finished
      end


      @enemies.dup.each do |enemy| #end game when enemy passed the space.
        if enemy.y > SCREEN_HEIGHT + enemy.radius 
          initialize_end(:enemy_passed)
        end 
      end 
      
      @missiles.dup.each do |friend_missile| 
        @missiles.delete friend_missile unless friend_missile.onscreen? 
      end
      initialize_end(:count_reached) if @enemies_appeared > MAX_ENEMIES
      initialize_end(:off_top) if @player.y < -@player.radius
    end

    def draw_game 
      @background_game.draw(0, 0, 0)
      draw_player @player
      @enemies.each do |enemy| 
        draw_enemy enemy
      end 
      @missiles.each do |friend_missile| 
        draw_friend_missile friend_missile
      end 
      @explosions.each do |explosion| 
        draw_explosion explosion
      end 

      #This part informs players about how many enemies appeared and destroyed by player
      #(cited on initialize_game)
      @font.draw(@news,650,50,1,1,1,Gosu::Color::YELLOW) 
      @font.draw(@enemies_appeared,750,100,1,1,1,Gosu::Color::YELLOW) 
      @font.draw(@news_2,650,150,1,1,1,Gosu::Color::WHITE) 
      @font.draw(@enemies_destroyed,750,200,1,1,1,Gosu::Color::WHITE) 
    end

    def button_down_game(id)
      if id == Gosu::KbF || id == Gosu::KbSpace #conditions to shoot missiles.
          @missiles.push Friend_Missile.new(self, @player.x, @player.y, @player.angle)
          @shooting_sound.play(0.3)
      end
    end
    

    def initialize_end(fate) 
      case fate 
      when :count_reached 
        @message = "You made it! You destroyed #{@enemies_destroyed} aircrafts." 
        @win_song = Gosu::Sampleample.new("audio/win.wav") 
        @win_song.play(true)
      when :hit_by_enemy 
        @message = "You were struck by an enemy aircraft." 
        @message2 = "Before your plane was destroyed, " 
        @message2 += "you took out #{@enemies_destroyed} enemy aircrafts." 
      when :off_top 
        @message = "You got too close to the enemy base." 
        @message2 = "Before your plane was destroyed, " 
        @message2 += "you took out #{@enemies_destroyed} enemy aircrafts."   
      when :enemy_passed
        @message = "You have let enemy aircraft passing through the airspace to your homeland."
        @message2 = "Before doing that, " 
        @message2 += "you took out #{@enemies_destroyed} enemy aircrafts." 
      end
      @background_end = Gosu::Image.new("images/endgame.png")
      @message_font = Gosu::Font.new(28) 
      @credits = []
       y = 700 
      File.open('credits.txt').each do |line| 
        @credits.push(Credit.new(self,line.chomp,100,y)) 
        y += 30 
      end 
      @scene = :end 
      @lose_song = Gosu::Sample.new("audio/lose.wav")#losing song
      @lose_song.play
      @end_game_song = Gosu::Song.new("audio/EndoftheEra.ogg")
      @end_game_song.play(false)
    end 


    def draw_end 
     @background_end.draw(0, 0, 0)
      clip_to(50,220,700,375) do 
        @credits.each do |credit| 
          draw_credit credit
        end 
      end 
      draw_line(0,220,Gosu::Color::RED,SCREEN_WIDTH,220,Gosu::Color::RED) 
      @message_font.draw(@message,40,40,1,1,1,Gosu::Color::AQUA) 
      @message_font.draw(@message2,40,75,1,1,1,Gosu::Color::AQUA) 
      draw_line(0,600,Gosu::Color::RED,SCREEN_WIDTH,600,Gosu::Color::RED)  
    end 

    def update_end 
      @credits.each do |credit| 
        move_credit credit
      end 
      if @credits.last.y < 150 
        @credits.each do |credit| 
          reset_credit credit
        end 
      end 
    end 


    def button_down_end(id) 
      if id == Gosu::KbP 
        initialize_game 
      elsif id == Gosu::KbR
        initialize
      elsif id == Gosu::KbQ 
        close 
      end 
    end
end 



window = AirStrike.new 
window.show