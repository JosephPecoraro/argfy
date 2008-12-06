require 'ARGFy'

argf = ARGFy.new(ARGV)
argf.each do |line|

	# Per File Header
	if argf.new_file?
		filename = argf.filename
		filename = "STDIN" if filename == "-"
		puts '', filename, "-"*filename.length
	end

	# Print out the line with line numbers
	puts "%3d: %s" % [argf.filelineno, line]

end
puts
