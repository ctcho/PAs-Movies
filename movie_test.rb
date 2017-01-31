class MovieTest
  def initialize(test_data)
    @test_data = Hash.new # a Hash. Key = user_id, Value = Hash of Key: movie_id, Value = [prediction_value, actual_rating]
    @test_data = test_data
    #puts @test_data.class #Hash
    #puts @test_data["1"].class #Hash: So the file passes in as expected. The question is how to work with it, then...
  end

#The error is the difference between the predicted value and the actual value, divided by the actual value.
#This method returns the average prediction error.
  def mean
    total = 0
    values = 0
    movie_set = @test_data.keys
    for entry in movie_set
      pairs = @test_data[entry].values #Gets the [predicted_value, actual_value] of each movie the user has seen
      for pair in pairs
        total += error(pair[0], Integer(pair[1]))
        values += 1
      end
    end
    return total/values
  end

#Since the mean method does this for the entire set, I thought it would be good to make a method for it for future use.
# Calculating error is explained in the mean method.
def error(predicted, actual)
  return ((predicted - actual)/actual).abs.to_f
end

#Standard deviation is calculated by taking the summation of the square of every value in a set minus the mean.
#You then take the square root of the answer.
  def stddev
    total = 0
    value = 0
    avg = mean # The mean method
    movie_set = @test_data.keys
    for entry in movie_set
      pairs = @test_data[entry].values #Gets the [predicted_value, actual_value] of each movie the user has seen
      for pair in pairs
        #puts "#{pair}"
        #puts pair[0]
        #puts pair[1]
        total += (error(pair[0], Integer(pair[1])) - avg) * (error(pair[0], Integer(pair[1])) - avg)
        value += 1
      end
    end
    return Math.sqrt(total/(value - 1))
  end

# Short for "root-mean-square." It takes the sum of the squares of every value in a set, divides the result
# by the number of values in the set and takes the square root of that result.
  def rms
    total = 0
    value = 0
    movie_set = @test_data.keys
    for entry in movie_set
      pairs = @test_data[entry].values #Gets the [predicted_value, actual_value] of each movie the user has seen
      for pair in pairs
        total += (error(pair[0], Integer(pair[1]))) * (error(pair[0], Integer(pair[1])))
        value += 1
      end
    end
    return Math.sqrt(total/value)
  end

# Returns an array of format [user_id, movie_id, actual_rating, predicted_rating].
  def to_a
    #puts @test_data.keys
    #puts @test_data.values
    predictions = []
    movie_set = @test_data.keys
    for entry in movie_set
      #puts entry.class
      pairs = @test_data[entry].keys #Grabs all the movies a User has seen
      for pair in pairs #Note: "pair" = movie_id
        predictions = predictions.push(entry, pair, @test_data[entry][pair][1], @test_data[entry][pair][0])
      end
    end
    return predictions
  end
end
