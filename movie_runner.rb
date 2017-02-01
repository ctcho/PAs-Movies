#This is the basic file that runs both movie_data.rb and movie_test.rb.
require_relative "movie_data.rb"
require_relative "movie_test.rb"

#Note that you can change the file path and specific test set to be what you need it to be.
data_base = MovieData.new("/vagrant/Desktop/CS166b/ml-100k/ml-100k", :u1)
test_set = Hash.new
test_set = data_base.run_test(10000)
tester = MovieTest.new(test_set)
#puts "This is the list of entries in the test set: #{tester.to_a}" #Printing this is obnoxious...
puts "This is the average error of the algorithm: #{tester.mean}"
puts "This is the standard deviation of the algorithm: #{tester.stddev}"
puts "This is the root-mean-square error of the algorithm: #{tester.rms}"
