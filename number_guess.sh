#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$(shuf -i 1-1000 -n 1)
echo "Enter your username:"
read USERNAME
USER_IN_DATA=$($PSQL "select name from users where name='$USERNAME'")
echo $USER_IN_DATA
if [[ -z $USER_IN_DATA ]]
then 
INSERT_NEW_USER=$($PSQL "insert into users(name) values('$USERNAME')")
USER_ID=$($PSQL "select user_id from users where name='$USERNAME'")
INSERT_NEW_RESULT=$($PSQL "insert into results(user_id,games_played) values($USER_ID,0)")
echo "Welcome, $USERNAME! It looks like this is your first time here."
else 
USER_ID=$($PSQL "select user_id from users where name='$USERNAME'")
echo $USER_ID
GAMES_PLAYED=$($PSQL "select games_played from results inner join users using(user_id) where name='$USERNAME'")
echo $GAMES_PLAYED
BEST_GAME=$($PSQL "select best_game from results inner join users using(user_id) where name='$USERNAME'")
echo "Welcome back, $USER_IN_DATA! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
echo "Guess the secret number between 1 and 1000:"
UPDATE_GAMES_PLAYED=$(($GAMES_PLAYED + 1))
ADD_NEW_GAMES_PLAYED=$($PSQL "update results set games_played=$UPDATE_GAMES_PLAYED where user_id=$USER_ID")
read USER_TRY
NUMBER_OF_GUESSES=1
while [[ $USER_TRY != $RANDOM_NUMBER ]]
do
if [[ !($USER_TRY =~ ^[0-9]+$) ]]
then
echo "That is not an integer, guess again:"
else
if [[ $USER_TRY < $RANDOM_NUMBER ]]
then echo "It's higher than that, guess again:"
else echo "It's lower than that, guess again:"
fi
fi
read USER_TRY
NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
done
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
PREVIOUS_BEST=$($PSQL "select best_game from results inner join users using(user_id) where name='$USERNAME'")
if [[ (-z $PREVIOUS_BEST) || ($NUMBER_OF_GUESSES < $PREVIOUS_BEST) ]]
then 
UPDATE_BEST=$($PSQL "update results set best_game=$NUMBER_OF_GUESSES where user_id=$USER_ID")
fi