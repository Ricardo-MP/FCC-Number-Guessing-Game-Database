#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USERNAME

#get user info
USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

#if username is not registered
if [[ -z $USER_INFO ]]
then
  #insert new user
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  USER_INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  #save user info in variables
  IFS='|' read GAMES_PLAYED BEST_GAME <<< $USER_INFO
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#generate random number
SECRET_NUMBER=$((1 + $RANDOM % 10))
GUESSES=1  

#read first guess
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

#while user guess doesn't match secret number
while [[ $GUESS != $SECRET_NUMBER ]]
do
  #if guess is not an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  else
    #increment number of guesses
    GUESSES=$(($GUESSES + 1))

    #if guess is lower than secret number
    if [[ $SECRET_NUMBER -lt $GUESS ]]
    then
      echo -e "\nIt's lower than that, guess again:"
    else
      echo -e "\nIt's higher than that, guess again:"
    fi
  fi
  
  #read guess again
  read GUESS
done

if [[ -z $BEST_GAME || $GUESSES -lt $BEST_GAME ]]
then
  UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=games_played + 1, best_game=$GUESSES WHERE username='$USERNAME'")
else
  UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=games_played + 1 WHERE username='$USERNAME'")
fi
  

echo -e "\nYou guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
