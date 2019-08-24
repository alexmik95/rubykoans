# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
#
# You already have a DiceSet class and score function you can use.
# Write a player class and a Game class to complete the project.  This
# is a free form assignment, so approach it however you desire.

class Game
  MAXPLAYERS = 10
  attr_reader :players
  attr_reader :final_round

  def initialize
    @final_round = false
  end

  def gen_players
    @players = Array.new
    # asks user for integer input and sanityzes
    print "how many players(2>n>#{MAXPLAYERS})? "
    n_players = gets.chomp.to_i
    if !check_input(n_players.to_s)
      raise "wrong input"
    end          
    if n_players < 2 or n_players > MAXPLAYERS
      raise "too much players"
    end
    # populates variable @players with new players
    n_players.times { |i| @players << Player.new("player#{i+1}") }
  end

  # regexp return 0 only if input is a valid integer else nil
  def check_input(input)
    input =~ /^\d+$/
  end

  # check if some player reached 3000 points
  def final_round?
    @players.each do |p|
      if p.score > 3000
        @final_round = true
        break
      end
    end
  end


  def turn(player)
    d = DiceSet.new
    score = 0
    dice = 5  # initial number of dice
    stop = false
    # while dice aren't all null or player with score 300+ wants to stop
    while !stop do
      partial = d.score(d.roll(dice))
      #puts partial
      # if all null stop rolling
      # stop = true if d.notnull == 0
      if partial > 0
        score += partial
        # if player's score 300+ can choose to stop
        # if had alreday 300+ can choose to stop anytime he wants
        # in this case calculated as random 0/1 -> false/true 
        if player.score >= 300 or score >= 300
          stop = player.continue_rolling?
          #puts "players stop: #{stop}"
        end 
        # number of dice for the next roll
        dice = dice == d.notnull ? 5 : d.notnull
        #puts "next roll dice: #{dice}"
        # if all dice are null, player lose points and passes the turn
      else
        score = 0
        stop = true
      end
      #puts "round score: #{score}"
    end
    # only the players who stopped accumulates points achived
    @players[players.find_index(player)].score += score
  end

  def round
=begin
    print "START ROUND\n"
    @players.each do |p|
      print "#{p.name}: #{p.score}\nSTART TURN\n"
      turn(p)
      print "END TURN\n"
    end
    print "END ROUND\n"
=end
    # CODE REFACTORING
    @players.each { |p| turn(p) }
  end

  def ranking
    rank = Hash.new
    @players.each do |p|
      if !rank.key?(p.score)
        rank[p.score] = []
      end
      rank[p.score] << p.name
    end
    #puts rank.keys.max
    result = rank.to_a.sort.reverse
    result.each { |x, y| print "#{x} #{y}\n" }
  end
end

class Player
  attr_reader :name
  attr_accessor :score

  def initialize(name)
    @name = name
    @score = 0
  end

  def continue_rolling?
    random = rand(0..1)
    #puts "random: #{random}"
    result = (random == 1) ? true : false
  end
end

class DiceSet
  attr_reader :values
  attr_reader :notnull

  def roll(dice)
    @values = (1..dice).map{ rand(1...6) }
  end

  def score(dice)
    result = 0
    @notnull = dice.size
    # checks number of dice thrown
    if (dice.size < 1 or dice.size > 5)
      return result
    end
  
    # inserts all value in a new hash collection
    # where duplicate value increases the count
    dice_hash = Hash.new(0)
    dice.each { |d| dice_hash[d] += 1 }
    # for each key checks if count is greater than three
    # and add the respective score to result
    dice_hash.each do |die, count|
      if count >= 3
        if die == 1
          result += 1000
        else
          result += die*100
        end
      # subctracts three to check next for remaining one or five
        count -= 3
      end
      # adds score for eventually remaining one or five
      result += (die == 1 ? count * 100 : 0)
      result += (die == 5 ? count * 50 : 0)
      @notnull -= (die != 1 and die != 5 and count > 0) ? count : 0
    end
  
    return result
  end
end

def main
  game = Game.new
  game.gen_players
  puts "playing..."
  while !game.final_round
    game.round
    game.final_round?
  end
  #puts "LAST ROUND"
  game.round
  #puts "END GAME"
  puts "RANKING:"
  game.ranking
end

main
