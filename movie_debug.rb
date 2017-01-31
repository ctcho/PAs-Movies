require_relative "movie_data.rb"
require_relative "movie_test.rb"

data_base = MovieData.new("/vagrant/Desktop/CS166b/ml-100k/ml-100k", :u1)
test_set = Hash.new
test_set = data_base.run_test()
tester = MovieTest.new(test_set)
#puts "This is the list of entries in the test set: #{tester.to_a}"
puts "This is the average error of the algorithm: #{tester.mean}"
puts "This is the standard deviation of the algorithm: #{tester.stddev}"
puts "This is the root-mean-square error of the algorithm: #{tester.rms}"
