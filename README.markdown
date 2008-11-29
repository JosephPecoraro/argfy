# ARGFy - a more flexible ARGF

This class is a more flexible version of the ARGF global.
The constructor takes an array, a list of files, and processes
them like one constant stream of input.  Reading from the
stream is always line by line either all at once using `each`
or one at a time using `gets`.

## Advantages

Although it acts like a stream, `ARGFy` keeps more information
about the current input file.  These internal attributes are:

  * _lineno_     - line number of the entire stream
  * _filelineno_ - line number of the current file
  * _filename_   - current file being processed

## Example

This is a simple program that prints out each file with
a simple header when the input files change.  It shows
the main advantage of this class over ARGF.

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
      puts "%3d: %s" % [argf.lineno, line]
    
    end

## Contact

  * _Author_: Joseph Pecoraro [email](mailto:joepeck02@gmail.com)
  * _Website_: [http://blog.bogojoker.com](http://blog.bogojoker.com)
  * _Copyright_: Copyright (c) 2008 Joseph Pecoraro
  * _License_: Distributes under the same terms as Ruby
