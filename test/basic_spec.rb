# Basic Tests for ARGFy
require '../ARGFy'

describe ARGFy, " with my two files" do
	
	before(:all) do
		@file1 = 'in1.txt'
		@file2 = 'in2.txt'
    @files = [@file1, @file2]
		@in1 = File.read( @file1 )
		@in2 = File.read( @file2 )
		@in1_lines = File.readlines( @file1 )
		@in2_lines = File.readlines( @file2 )
  end

	before(:each) do
		@argf = ARGFy.new( @files )
		@argfrev = ARGFy.new( @files.reverse )
	end


  it "should show 2 different files" do
		@argf.inject( count=0 ) { |mem, line| count += 1 if @argf.new_file? }
    count.should == 2
  end


	it "should be able to grow with add_file" do
		three_in1 = @in1 * 3
		@argfl = ARGFy.new([@file1])
		@argfl.add_file(@file1)
		@argfl.add_file(@file1)
		str = @argfl.inject('') { |mem, line| mem += line }
		str.should == three_in1
	end


	it "should be able to get lines individually and in order" do
		@in1_lines.each { |line| line.should == @argf.gets }
		@in2_lines.each { |line| line.should == @argf.gets }
		@in2_lines.each { |line| line.should == @argfrev.gets }
		@in1_lines.each { |line| line.should == @argfrev.gets }
	end


  it "should be able to the two files continuously and in order" do
		str = @argf.inject('') { |mem, line| mem += line }
		str.should == (@in1 + @in2)		
		str = @argfrev.inject('') { |mem, line| mem += line }
		str.should == (@in2 + @in1)		
	end


	it "should not lose place when calling each inside gets" do
		input = @in1_lines * 2
		@argfl = ARGFy.new( [@file1, @file1] )
		i = 0
		until (line = @argfl.gets).nil?
			line.should == input[i]
			i += 1
			j = 0
			@argfl.each do |line2|
				line2.should == input[j]
				j += 1
			end
		end
	end
	
	
	it "should count correctly for everything" do
		@argf.inject(1) { |mem, line| @argf.lineno.should == mem; mem += 1 } 
		count = 0
		until (line = @argfrev.gets).nil?
			count += 1
			@argfrev.lineno.should == count
		end
	end


	it "should count correctly per file" do
		count = 0
		change = true
		@argf.each do |line|
			count += 1
			if change && count > @in1_lines.size
				change = false
				count = 1
			end
			@argf.filelineno.should == count
		end
		count = 0
		change = true
		until (line = @argfrev.gets).nil?
			count += 1
			if change && count > @in2_lines.size
				change = false
				count = 1
			end
			@argfrev.filelineno.should == count
		end
	end


	it "should have the correct filename for each file" do
		@argf.inject( list=[] ) { |mem, line| list.push(@argf.filename) if @argf.new_file? }
		list.should == @files
		list = []
		until (line = @argfrev.gets).nil?
			list.push(@argfrev.filename) if @argfrev.new_file?
		end
		list.should == @files.reverse
	end


	it "should be able to do Enumerable stuff" do
		list = @argf.inject([]) { |mem, line| mem.push(line) }
		list.should == (@in1_lines+@in2_lines)
	end

end
