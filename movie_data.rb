#require_relative "movie_test.rb"

class MovieData

  def initialize(directory_name, file_path = "nothing")
    @directory_name = directory_name
    @file_path = file_path
    @users = Hash.new # a Hash. Key = user_id, Value = Hash of Key: movie_id, Value = Rating
    @movies = Hash.new # a Hash. Key = movie_id, Value = Hash of Key: user_id, Value = Rating
    @predictions = Hash.new # a Hash. Key = user_id, Value = Hash of Key: movie_id, Value = [prediction_value, actual_rating]
    load_data
  end

# This gets the @users and @movies structures ready for use. The specifics of what happens is below.
  def load_data()
    if @file_path == "nothing" #reading all of the entries
      data_file = @directory_name + "/" + "u.data"
    else #We're interested in testing the prediction algorithm
      data_file = @directory_name + "/" + @file_path.to_s + ".base"
    end
    data_contents = open(data_file) # Obtain contents of movie reviews
    line_set = data_contents.readlines() # Put the movie reviews into an array, one review per slot
    for line in line_set
      data = line.split("\t")
      if @users.has_key?(data[0])
        addition = {data[1] => data[2]} #create a movie_id:rating pair
        @users[data[0]] = @users[data[0]].merge(addition) # add it to list of pairs for the user_id
      else
       @users[data[0]] = {data[1] => data[2]} # add the user_id and its first pair to the Hash
      end
      if @movies.has_key?(data[1])
        addition = {data[0] => data[2]}
        @movies[data[1]] = @movies[data[1]].merge(addition) # add rating to list for the movie_id
      else
        @movies[data[1]] = {data[0] => data[2]} # add the movie_id and its rating to the Hash
      end
    end
  end

# Returns a popularity rating of a movie based on how many people saw it and the ratings it received overall.
  def popularity(movie_id)
    if !@movies.has_key?(movie_id) #Is the movie in the data set?
      puts "That movie_id isn't in the data set."
      return nil
    end
    num_people = 0
    total_rating = 0
    #num_people is the number of people that reviewed the movie,
    #total_rating is the collective total of the ratings
    ratings = @movies[movie_id].values #creates an array of user_id:rating pairs for the particular movie
    for item in ratings
      num_people += 1
      total_rating += Integer(item)
    end
    return (num_people * 0.01) * total_rating #The premise is to make both ratings
    #and the number of people that rated the movie matter for popularity.
  end

# Returns a list of movies from most popular to least popular.
  def popularity_list()
    all_movies = @movies.keys()
    the_list = Hash.new
    for m in all_movies
      inverted = (popularity(m)) * -1
      # Why is this inverted? Because in sorting, it goes from least to greatest. By making every value negative, the smallest reviews
      #now come up first.
      the_list[m] = inverted
    end
    return the_list.sort_by {|movie_id, popularness| popularness} #This particular operation allows us to sort a hash based on the
    #numerical quantity of the values.
  end

# A comparison between two users. It works based off of which movies the two have seen and the disparity between the
# ratings each gave a movie.
  def similarity(user1, user2)
    if !@users.has_key?(user1)
      puts "user1 is not in the data set."
      return nil
    elsif !@users.has_key?(user2)
      puts "user2 is not in the data set."
      return nil
    end
    similar_movies = 0
    similar_rating = 0
    # The following sequence demonstrates that you only need to check the number of movies reviewed by
    # the user that has reviewed fewer movies.
    if @users[user1].length() < @users[user2].length()
      key_set = @users[user1].keys() # Just a more convenient way to check the movies user1 has reviewed.
      for item in key_set
      if @users[user2].has_key?(item)
        similar_movies += 1
        # This is incremented based on the disparity between the ratings the users gave for the same movie.
        # Since we want a higher value for closer similarity, this calculation accomplishes that request.
        similar_rating += (5 - (Integer(@users[user1][item]) - Integer(@users[user2][item])).abs)
      end
    end
    else
      key_set = @users[user2].keys() # Just a more convenient way to check the movies user2 has reviewed.
      for item in key_set
        if @users[user1].has_key?(item)
          similar_rating += (5 - (Integer(@users[user1][item]) - Integer(@users[user2][item])).abs)
        end
      end
    end
    if similar_movies > 0
      return similar_rating/similar_movies
    else # user1 and user2 had absolutely nothing in common.
      return 0
    end
  end

# As the method name suggests, it returns a list of users most similar to the one specified.
  def most_similar(user)
    user_list = @users.keys()
    candidates = []
    for u in user_list
      if u != user
        if similarity(user, u) >= 4.0 #It says MOST similar. Only those that really match up are considered.
          candidates.push(u)
        end
      end
    end
    return candidates
  end

# This gets @predictions ready for use. It follows the same setups as @users and @movies does,
# except the format of @predictions is somewhat different.
# It then returns the result to a MovieTest object for use.
  def run_test(number = 0)
    if @file_path == "nothing"
      puts "This MovieData object does not have the functionality for testing."
      return nil
    end # Only 20,000 lines in a test set.
    test_line = @directory_name + "/" + @file_path.to_s + ".test"
    test_contents = open(test_line)
    test_line_set = test_contents.readlines
    i = 0
    if number != 0 #if we're only interested in a small number of predictions
      while i < number
        if i % 1000 == 0
          puts "Prediction dataset generation in progress: #{((i / number) * 100).to_f}%"
        end
        line = test_line_set[i].split("\t")
        if @predictions.has_key?(line[0]) # Remember, an entry is [user_id, movie_id, rating, timestamp]
          addition = {line[1] => [predict(line[0], line[1]), line[2]]} # An array of [predicted_rating, actual_rating] is easier than a hash this time.
          @predictions[line[0]] = @predictions[line[0]].merge(addition)
        else
          @predictions[line[0]] = {line[1] => [predict(line[0], line[1]), line[2]]}
        end
        i += 1
      end
    else # We want the whole test set
      for line in test_line_set # same as before, just with more iterations.
        i += 1
        if i % 1000 == 0
          puts "Prediction dataset generation in progress: #{((i / 20000) * 100).to_f}%"
        end
        data = line.split("\t")
        if @predictions.has_key?(data[0])
          addition = {data[1] => [predict(data[0], data[1]), data[2]]}
          @predictions[data[0]] = @predictions[data[0]].merge(addition)
        else
          @predictions[data[0]] = {data[1] => [predict(data[0], data[1]), data[2]]}
        end
        #puts @predictions[data[0]].class
      end
    end
    test_set = @predictions
    return test_set
  end

# Returns the rating a user gave a movie. If the user didn't rate the movie, return 0.
  def rating(user, movie)
    if @users[user].has_key?(movie)
      return Integer(@users[user][movie])
    else
      return 0
    end
  end

# The way I did my prediction algorithm is as follows:
# Get the list of users most similar to the user.
# Check every user in the list if they've seen the movie in question.
# Take the average of the total ratings of every user that saw the movie, and return that as the predicted rating.
  def predict(user, movie)
    list = most_similar(user)
    rate_total = 0
    total_number = 0
    for u in list
      if @users[u].has_key?(movie)
        total_number += 1
        rate_total += rating(u, movie)
      end
    end
    if total_number != 0
      return rate_total/total_number
    else
      return 0
    end
  end

# Returns a list of movies the user has seen.
  def movies(user)
    return @users[user].keys
  end

# Returns a list of viewers that have seen the movie.
  def viewers(movie)
    return @movies[movie].keys
  end
end


#And here are the commands that show that the program works as intended.
#reviewer = MovieData.new("/vagrant/Desktop/CS166b/ml-100k/ml-100k", :u1)
#popular_movies = reviewer.popularity_list()
#i = 0
#puts "A few popular (and not so popular movies) by id:"
#while i < popular_movies.length
#  if i <= 10 || i + 10 > popular_movies.length() - 1 # first 10 and last 10 datas
#    puts popular_movies[i][0]
#  end
#  i += 1
#end
#puts "A list of users most similar to user 1 by id: "
#j = 0
#similar_users = reviewer.most_similar("1")
#while j < similar_users.length()
#  if j <= 10 || j + 10 > similar_users.length() - 1 # first 10 and last 10 users
#    puts similar_users[j]
#  end
#  j += 1
#end
