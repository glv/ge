#!/usr/bin/env ruby

# I'm trying to keep the code here ordered more or less as it is in
# the original BASIC listing, to the extent that it doesn't prevent
# writing good, idiomatic Ruby code. Where I've factored new routines
# out of the original logic, those are placed at the bottom.
module GE
  class Game
    # game configuration info (does not change after game starts)
    attr_reader :players, :worlds, :turns       # integers
    attr_reader :autobuild                      # booleans
    attr_reader :player_worlds, :extra_worlds   # ranges
    attr_reader :stars, :industries, :controls, :ships  # arrays

    # game tracking info (changes each turn)
    attr_reader :turn

    # 50-220
    def initialize
      @turn = 0
      @ships = []
    end

    # 230-510
    def play
      print_rules
      gather_parameters
      puts "  players: #{players}"
      puts "   worlds: #{worlds}"
      puts "    turns: #{turns}"
      puts "autobuild: #{autobuild}"
      generate_star_locations
      generate_industries
      set_initial_world_control
      build_ships
      print_star_locations
      print_world_data
      begin
        turn += 1
        fleet_orders
        build_new_ships
        move_fleets
        print_world_data
      end while turn < turns
      # TODO: wrapup
    end

    protected

    # 540-630
    def bell # illegal input
      puts "\a"
    end

    # other sounds:
    # 650-700 defender's fire
    # 720-770 hit

    # 790-1220
    def combat_subroutine
      # TODO:
    end

    # 1240-1690
    def fleet_order_input
      # TODO:
    end

    # 1710-1750
    def chartr_input
      # TODO:
    end

    # 1770-1820
    def distance(w1, w2)
      radicand = (stars[w1][0] - stars[w2][0]) ** 2 + (stars[w1][1] - stars[w2][1]) ** 2
      Math.sqrt(radicand).to_i
    end

    # 1840-1870
    def print_rules
      puts
    end

    # 1890-2120
    def gather_parameters
      @players = get_int_input("How many players (1-20)") do |val|
        (1..20).include?(val)
      end
      @player_worlds = (0...players)

      @worlds = get_int_input("How many worlds (#{players}-40)") do |val|
        (players..40).include?(val)
      end
      @extra_worlds = (players...worlds)

      @turns = get_int_input("How many turns in the game (1-100).") do |val|
        (1..100).include?(val)
      end

      @autobuild = get_bool_input("Do you want the neutral worlds to build defensive ships")
    end

    # 2140-2360 (including print_star_map)
    def generate_star_locations
      loop do
        x_coords = (1..20).to_a
        y_coords = (1..20).to_a
        @stars = x_coords.product(y_coords).sample(worlds)
        print_star_map
        repeat = get_bool_input("New setup")
        break unless repeat
      end
    end

    # 2240-2360
    # Rob Pike's bio (http://herpolhode.com/rob/) states that he "has
    # never written a program that uses cursor addressing". While not
    # as proud of it as he apparently is, I've always been pleased by
    # the fact that I could say the same thing. Well, here goes
    # nuthin'.
    def print_star_map
      clear_screen
      cursor_position(1, 1)
      print "*******STAR MAP*******"
      stars.each_with_index do |(x, y), i|
        cursor_position(x*2-1, y+1)
        print i+1
      end
      cursor_position(1, 22)
    end

    # 2380-2440
    def generate_industries
      @industries = Array.new(players, 10) # player worlds
      @industries += (extra_worlds).map{rand(1..5)} # neutral worlds
    end

    # 2460-2490
    def set_initial_world_control
      @controls = player_worlds.to_a + extra_worlds.collect{0}
    end

    # 2510-2660
    def build_ships
      player_worlds.each do |pw|
        denom = extra_worlds.map{|ew| 100 / (distance(pw, ew) + 2)}.inject(0){|accum, n| accum + n }
        ships[pw] = worlds * (5 + 400/denom)
      end
      extra_worlds.each do |ew|
        ships[ew] = 0
        # about a third of the extra worlds should get an extra ship allocation
        allocations = rand(3) == 0 ? 2 : 1
        allocations.times{ ships[ew] += rand(0...industries[ew]) + 3 }
      end
    end

    # 2680-2810
    def print_star_locations
      clear_screen
      cursor_position(1, 1)
      print "WORLD  X   Y"
      cursor_position(21, 1)
      print "WORLD  X   Y"
      puts
      col_division = (worlds + 1) / 2
      stars.each_with_index do |(x, y), i|
        row = (i % col_division) + 2
        col = (i / col_division) * 21
        cursor_position(col, row)
        print "%2d     %2d  %2d" % [i, x, y]
        # puts "col: #{col}, row: #{row}"
      end
      cursor_position(1, col_division + 2)
      puts "PREPARE YOUR STRMAP USING THE ABOVE"
      puts "DATA. ON A SHEET OF GRAPH PAPER MAKE A"
      puts "20X20 GRID WITH 0,0 IN THE UPPER LEFT."
      get_input("TYPE GO WHEN YOU ARE FINISHED"){true}
    end

    # 2830-3000
    def fleet_orders
      players.times do |i|
        fleet_order_input
      end
    end

    # 3020-3070
    def build_new_ships
      # TODO:
    end

    # 3090-3180
    def move_fleets
      # TODO:
    end

    # 3200-3340
    def print_world_data
      clear_screen
      cursor_position(1, 1)
      print "RESULTS FOR TURN #{turn}"
      cursor_position(1, 2)
      print "WRLD CONT PROD SHPS WRLD CONT PROD SHP"
      col_division = (worlds + 1) / 2
      worlds.times do |i|
        world = i+1
        row = (i % col_division) + 3
        col = (i / col_division) * 21
        cursor_position(col, row)
        print "%2d    %2d" % [world, controls[i]]
        if controls[i] != 0
          cursor_position(col+11, row)
          print industries[i]
          cursor_position(col+16, row)
          print ships[i]
        end
      end
      cursor_position(1, col_division + 3)
    end

    # New routines below here

    def prompt(text)
      # TODO: wrap to 40 characters
      print text.upcase + " "
    end

    # Prompts the user for a game parameter. Yields the user's
    # input to a block for validation and format conversion.
    # The block must either return the validated parameter value
    # or throw(:invalid).
    def get_input(prompt_string)
      loop do
        catch(:invalid) do
          prompt prompt_string
          input = gets.chomp
          return yield(input)
        end
        bell
      end
    end

    # Prompts the user for an integer game parameter. Yields
    # the integer to a block for range validation; the block
    # must return a truthy value if the parameter is valid,
    # false otherwise.
    def get_int_input(prompt_string, &range_validation_proc)
      get_input(prompt_string) do |input|
        throw(:invalid) unless input =~ /^\d+$/
        input.to_i.tap{|ival|
          throw(:invalid) unless range_validation_proc.(ival)
        }
      end
    end

    def get_bool_input(prompt_string)
      get_input(prompt_string) do |input|
        case input
        when /^Y/ then true
        when /^N/ then false
        else throw(:invalid)
        end
      end
    end

    def clear_screen
      print "\e[2J"
    end

    def cursor_position(x, y)
      print "\e[#{y};#{x}H"
    end
  end
end

GE::Game.new.play
