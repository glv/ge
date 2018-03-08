#!/usr/bin/env ruby

module GE
  class Game
    attr_reader :players, :worlds, :turns, :autobuild

    def play
      print_rules
      gather_parameters
      puts "  players: #{players}"
      puts "   worlds: #{worlds}"
      puts "    turns: #{turns}"
      puts "autobuild: #{autobuild}"
    end

    def prompt(text)
      # TODO: wrap to 40 characters
      print text.upcase + " "
    end

    # 540
    def bell
      puts ""
    end

    # 1840
    def print_rules
      puts
    end

    def get_parameter(prompt_string)
      prompt prompt_string
      input = gets.chomp
      yield(input)
    rescue RuntimeError
      bell
      retry
    end

    def get_int_parameter(prompt_string, &range_validation_proc)
      get_parameter(prompt_string) do |input|
        raise unless input =~ /^\d+$/
        input.to_i.tap{|ival| raise unless range_validation_proc.(ival) }
      end
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

      @autobuild = get_parameter("Do you want the neutral worlds to build defensive ships") do |input|
        case input
        when /^Y/ then true
        when /^N/ then false
        else raise
        end
      end
    end

    # These are all as-yet-unnamed procs that are the targets of GOSUBs
    # 2140
    def c
    end

    # 2240
    def d
    end

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
  end
end

GE::Game.new.play
