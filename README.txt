Author: Cameron Cho

This README.txt pertains to PA1, Part 1: Movies.

On Creating a Solution: Method Implementation
0. MovieData.initialize
  a. In this method, I created two fields for the object:
    i. @users: This is a Hash that is meant to contain a list of users, and for every user, there
    is a list of movies they have rated, along with the given rating. The Hash contains the following:
      - Key: user_id
      - Value: Another Hash that contains the following:
        > Key: movie_id
        > Value: rating
    ii. @movies: This is also a Hash, meant to contain a list of movies, and for every movie, there is a list
    of ratings it was given. The Hash contains the following:
      - Key: movie_id
      - Value: An Array of ratings
  b. The purpose of creating the fields like this was to help organize the data from the input file into something fairly
  straightforward. It made sense to create a @users as a list users, with their values being a list of the movies they had reviewed,
  along with the review they gave each movie. However, it did not make sense for the movies in @movies to remember
  whom they were rated by, only that they were rated. Every movie did retain an array  of ratings to keep track of how many times
  it was rated and the value it was given for each rating.

1. MovieData.load_data
  a. For simplicity's sake, I chose to have the method start by prompting the user to give the object a data file to use.
  b. Then, it breaks the given file up into an array of lines.
  c. For every line in the array of lines:
    i. It breaks the line up into an array, split on tabs.
    ii. If @users had the user_id in the line, it adds the movie_id and rating as a pair to the list of movie_id:rating pairs the given
    user_id already has. If @users did not have the given user_id, it creates a new key for @users that contains user_id with its movie_id:
    rating pairing as its first value.
    iii. A similar procedure follows for @movies: if @movies has the given movie_id, it adds to its array of ratings the given rating. If the
    given movie_id is not in @movies, it adds the movie_id to the list of keys with the given rating as its first entry in its value of arrays.

2. MovieData.popularity(movie_id)
  a. It first checks to see if the given movie_id is located in @movies. Remember that the passed in value needs to be of type String,
  or it won't be able to find the given movie_id, ever.
  b. If it has found the movie_id in @movies, the method creates two tracker variables, num_people and total_rating, along with an array that
  contains all the ratings the particular movie_id has.
  c. Then, for every rating in the given movie_id:
    i. Add the integer value of the rating to the running total_rating.
    ii. Increase num_people by 1.
  d. I defined popularity based on two dimensions:
    i. How many reviews has the movie gotten? This is where num_people comes from. The movie might have ratings of all 5's, but if only 3
    people reviewed it, the movie can't be considered popular. Likewise, if the movie has had over 200 people review it, but most of the
    ratings are 1's or 2's, then you can't say the movie is popular, either, even with all the reviews.
    ii. How good are the ratings the movie has received? This is where total_rating comes from. If it has a rather low value, people did not
    like the movie and it can't be popular. Likewise, if total_rating is very high, it can be considered popular.
  e. Based on the two given dimensions, I created a simple calculation that incorporates both the number of reviews a movie got and how highly
  people rated the movie to give an estimate of the movie's popularity, and this value is returned to the user.

3. MovieData.popularity_list
  a. The method starts by getting all the keys in @movies and placing it in a temporary array.
  b. It also creates a temporary Hash that will be filled in later.
  c. For every movie in the array:
    i. popularity(movie_id) obtains the movie's popularity rating, then multiplies it by -1. The purpose of this is to help with how
    the list is to be sorted later.
    ii. Add the movie and its inverted popularity as a key-value pair to the temporary hash.
  d. It returns the temporary hash, but not before sorting it based on the popularity of each movie. This is why the value of the popularity
  for each movie was inverted: since Ruby organizes by least to greatest, the method worked around this by multiplying the popularity values
  by -1, so that it would return a list of movies from greatest popularity to least popularity.

4. MovieData.similarity(user1, user2)
  a. The method starts by checking if the given users are in @users.
  b. It then creates two tracker variables, similar_movies and similar_rating.
  c. The basis for comparing the similarity between two users is based on how many movies the both of them have reviewed and then comparing
  the ratings the two gave for the same movie. In addition, you only need to compare the number of movies equivalent to the user that has
  reviewed fewer movies than the other user.
  d. To this end, the method will use one of two for-loops, based on the user that reviewed fewer movies, but the process is still the same.
  For every movie that the user with fewer reviews has seen:
    i. Check to see if the second user has also reviewed the movie. If so, then add to similar_rating the disparity between the ratings the
    two users gave and increment similar_movies by 1. If the second user hasn't seen the movie the first has, do nothing.
  e. Return similar_rating divided by similar_movies. This will give a value between 1 and 5. It will return 0 if user1 and user2 had no movies
  in common.

5. MovieData.most_similar(user)
  a. The method takes every user in @users and compares them to the given user with similarity(user1, user2). If the given result is
  greater than or equal to 4.0, then the user is added to a list of people that can be considered most similar to the given user.
    i. The reason I used 4.0 as the standard is because the method wants people that are the MOST similar to the given user, and a 4.0 rating,
    based on how similarity(user1, user2) works, shows very little disparity between the tastes of two users.
  b. The list of most similar users is then returned.

6. The commands
  a. As required, the commands following the class give the 10 most and least popular movies, along with a list of 20 users most similar to
  user_id = 1. The results of running the code are in running_transcript_pa1_part1.txt.


On the Extra Considerations
1. To implement an algorithm that predicts how a certain user would rate a movie they have never seen before, this program would first need
more information than just a movie_id; there's not much you can tell from a number without context, after all. But given more information,
a predictor algorithm could be devised in one of two ways:
  a. There is a pattern to the movie_ids. The algorithm could then gather the nearest 20 or so movie_ids similar to the movie_id in question
  and average the ratings of those ids. The result could be an approximation (however crude it may be) of what rating the user would give the
  movie in question.
  b. We are given more information about the movies. The program would first need to store the extra information with the movie_ids, then gather
  the 20 or so most similar movies to the movie in question. Average the ratings, as suggested before, and return that as an approximation
  of how the user will rate the movie.

2. popularity_list probably takes the most time, since it deals with several arrays of a rather massive size. In particular, it needs to return
a sort of average for the popularity rating of each movie_id, of which there are several. It then needs to sort the resulting popularity list
from greatest to least. As the program is now, it is not very efficient at using space, especially concerning @movies' design, and therefore
scaling the program would slow down execution whenever @movies is involved. If I had more time, I would modify @movies so that it would
calculate the popularity rating from the beginning and use that as the value for the movie_id key instead of having an array of ratings, which
I believe would increase the speed of future operations.
- As for most_similar, I do not think I can be much more efficient than how I have @users currently set up. The main factors to its execution time
are the number of users in the hash and the number of movies that each user has reviewed. Should this program be scaled, it would naturally slow
down, but I do not believe that it would suffer as much of a slow down as it is compared to the slow down that popularity_list would experience.
-Overall, the program is "semi-scalable," with most_similar functioning without many problems but popularity_list suffering with the massive
sizes of the arrays and the sheer number of them. Again, it would be more scalable if I had chosen to calculate the popularity from the
beginning and assign the values to the movie_ids instead.
