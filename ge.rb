#!/usr/bin/env ruby

# I'm trying to keep the code here ordered more or less as it is in
# the original BASIC listing, to the extent that it doesn't prevent
# writing good, idiomatic Ruby code. Where I've factored new routines
# out of the original logic, those are placed at the bottom.
module GE
  class Game
    attr_reader :players, :worlds, :turns, :autobuild, :stars

    def play
      print_rules
      gather_parameters
      puts "  players: #{players}"
      puts "   worlds: #{worlds}"
      puts "    turns: #{turns}"
      puts "autobuild: #{autobuild}"
      generate_star_locations
    end

    protected

    # 540
    def bell
      puts ""
    end

    # 1840
    def print_rules
      puts
    end

    # 1890
    def gather_parameters
      @players = get_int_parameter("How many players (1-20)") do |val|
        (1..20).include?(val)
      end

      @worlds = get_int_parameter("How many worlds (#{players}-40)") do |val|
        (players..40).include?(val)
      end

      @turns = get_int_parameter("How many turns in the game (1-100).") do |val|
        (1..100).include?(val)
      end

      @autobuild = get_bool_parameter("Do you want the neutral worlds to build defensive ships")
    end

    # 2140
    def generate_star_locations
      loop do
        x_coords = (1..20).to_a
        y_coords = (1..20).to_a
        @stars = x_coords.product(y_coords).sample(worlds)
        print_star_map
        repeat = get_bool_parameter("New setup")
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
      # TODO: what does "CALL  - 936" do? (I'm guessing clear the screen)
      clear_screen
      cursor_position(1, 1)
      print "*******STAR MAP*******"
      stars.each_with_index do |(x, y), i|
        cursor_position(x*2-1, y+1)
        print i+1
      end
      cursor_position(1, 21)
    end

    # These are all as-yet-unnamed procs that are the targets of GOSUBs

    # 2380
    def e
    end

    # 2460
    def f
    end

    # 2510
    def g
    end

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
    def get_parameter(prompt_string)
      loop do
        catch(:invalid) do
          prompt prompt_string
          input = gets.chomp
          return yield(input)
          bell
        end
      end
    end

    # Prompts the user for an integer game parameter. Yields
    # the integer to a block for range validation; the block
    # must return a truthy value if the parameter is valid,
    # false otherwise.
    def get_int_parameter(prompt_string, &range_validation_proc)
      get_parameter(prompt_string) do |input|
        throw(:invalid) unless input =~ /^\d+$/
        input.to_i.tap{|ival|
          throw(:invalid) unless range_validation_proc.(ival)
        }
      end
    end

    def get_bool_parameter(prompt_string)
      get_parameter(prompt_string) do |input|
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
