#
# = ARGFy - a more flexible ARGF
#
# This class is a more flexible version of the ARGF global.
# The constructor takes an array, a list of files, and processes
# them like one constant stream of input.  Reading from the
# stream is always line by line either all at once using #each
# or one at a time using #gets.
#
#
# == Attributes
#
# Internal states can help your program understand what
# was processed when you pull any line:
#
# * _lineno_     - line number of the entire stream
# * _filelineno_ - line number of the current file
# * _filename_   - current file being processed
#
#
# == Example
#
# This is a simple program that prints out each file with
# a simple header when the input files change.  It shows
# the main advantage of this class over ARGF.
#
#     require 'ARGFy'
#     
#     argf = ARGFy.new(ARGV)
#     argf.each do |line|
#     
#       # Per File Header
#       if argf.new_file?
#         filename = argf.filename
#         filename = "STDIN" if filename == "-"
#         puts '', filename, "-"*filename.length
#       end
#     
#       # Print out the line with line numbers
#       puts "%3d: %s" % [argf.lineno, line]
#     
#     end
#
#
# == Contact
#
# Author::    Joseph Pecoraro (mailto:joepeck02@gmail.com)
# Copyright:: Copyright (c) 2008 Joseph Pecoraro
# License::   Distributes under the same terms as Ruby
#
class ARGFy
	
	# its enumerable, line by line
	include Enumerable
	
	# last line number read from the entire stream
	attr_accessor :lineno
	
	# last line number read from the current file
	attr_accessor :filelineno
	
	# filename of the current file being read
	attr_accessor :filename
		
	# Constructor takes an optional list of files, and will default
	# to just using STDIN on an empty list.
	def initialize(file_arr=[])
		@files = ["-"]
		@files = file_arr unless file_arr.empty?
		reset
	end
	
	# Sets the public and private states to their default values
	def reset
		@lineno = 0
		@filelineno = 0
		@filename = @files.first
		@index = 0
		@lines = nil
	end
	
	# Add a file to the file list
	def add_file(str)
		@files.push(str)
	end
	
	# Goes through the lines of all files constantly updating
	# the internal states _filename_, _lineno_, and _filelineno_.
	def each
		
		# Save States that this affects, and set them to defaults
		states = [@lineno, @filelineno, @filename]
		@lineno = 0;
		
		# Read every line walking through the files
		@files.each do |filename|
			
			# Setup States Per File
			@filename = filename
			@filelineno = 0
			stream = STDIN
			stream = File.open(filename) unless filename == '-'
			
			# Read Lines
			while line = stream.gets
				@lineno += 1
				@filelineno += 1
				yield line
			end
			
		end
		
		# Restore the original states
		@lineno, @filelineno, @filename = states
		
	end
	
	
	# Gets each line individually.
	def gets
		
		# Quick exit when depleted
		return nil if @index >= @files.size
		@filename = @files[@index]
		
		# Special case for STDIN
		# Handle a STDIN break right here
		if @filename == "-"
			line = STDIN.gets
			if line.nil?
				@index += 1
				@filelineno = 0
				return gets
			else
				@lineno += 1
				@filelineno += 1
				return line
			end
		end
		
		# Bulk read into @lines
		@lines = File.open(@filename).readlines if @lines.nil?
		
		# When Depleted, go to the next
		if @filelineno >= @lines.size
			@index += 1
			@filelineno = 0
			@lines = nil
			return gets
		end
		
		# Reads the line, updates internal variables
		line = @lines[@filelineno]
		@lineno += 1
		@filelineno += 1
		return line
		
	end
	
	# Returns true if the last line read was from a new file
	def new_file?
		@filelineno == 1
	end
	
end
