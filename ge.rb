#!/usr/bin/env ruby

# I'm trying to keep the code here ordered more or less as it is in
# the original BASIC listing, to the extent that it doesn't prevent
# writing good, idiomatic Ruby code. Where I've factored new routines
# out of the original logic, those are placed at the bottom.
module GE
  class Game
    attr_reader :players, :worlds, :turns       # integers
    attr_reader :autobuild                      # booleans
    attr_reader :player_worlds, :extra_worlds   # ranges
    attr_reader :stars, :industries, :controls  # arrays

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
    end

    protected

    # 540
    def bell
      puts "\a"
    end

    # 1840
    def print_rules
      puts
    end

    # 1890
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

    # 2140
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

    # 2240
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

    # 2380
    def generate_industries
      @industries = Array.new(players, 10) # player worlds
      @industries += (extra_worlds).map{rand(1..5)} # neutral worlds
    end

    # 2460
    def set_initial_world_control
      @controls = player_worlds.to_a
    end

    # 2510
    def build_ships
      player_worlds.each do |pw|
        denom = extra_worlds.map{|ew| 100 / (distance(pw, ew) + 2)}.sum
        ships[pw] = worlds * (5 + 400/denom)
      end
      extra_worlds.each do |ew|
        # TODO: something weird here ... on line 2640, it looks like a
        # third of the time (randomly) it will repeat this step for
        # the current star. Am I reading that correctly?
        ships[ew] += rand(0...industries[ew]) + 3
      end
    end

    # These are all as-yet-unnamed procs that are the targets of GOSUBs

    # 2680
    def h
    end

    # 3200
    def i
    end

    # 2830
    def j
    end

    # 3020
    def k
    end

    # 3090
    def l
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

    def distance(w1, w2)
      radicand = (stars[w1][0] - stars[w2][0]) ** 2 + (stars[w1][1] - stars[w2][1]) ** 2
      Math.sqrt(radicand).to_i
    end
  end
end

GE::Game.new.play
