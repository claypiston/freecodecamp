#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~ Random Number Guessing Game ~~~~\n"

# function for guessing game
GUESSING_GAME () {
# create random number
NUMBER_TO_GUESS=$(( $RANDOM % 1000 + 1))
# enter name
echo -e "\nEnter your username:"
read USERNAME
USERNAME_EXISTS=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
#creat new user
if [[ -z $USERNAME_EXISTS ]]
then
  USERNAME_INSERT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
# welcome new user
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
# else if user exists welcome get game number and min gueses
else
  INFO_SELECT=$($PSQL "SELECT name, COUNT(*), MIN(guesses) FROM users LEFT JOIN games USING(user_id) WHERE name = '$USERNAME' GROUP BY name")
  # welcome user
  echo $INFO_SELECT | while IFS="|" read NAME GAMES BEST_GAME
  do
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST_GAME guesses."
  done
fi

# set guesses to 0
GUESSES=0
GUESSED_NUMBER=-1
# start game
GAME_NUMBER=$($PSQL "SELECT MAX(game_number) FROM users LEFT JOIN games USING(user_id) WHERE name = '$USERNAME' GROUP BY name")
GAME_NUMBER=$(( $GAME_NUMBER + 1 ))
while [[ $GUESSED_NUMBER -ne $NUMBER_TO_GUESS ]]
do
  if [[ $GUESSES -eq 0 ]]
  then
    echo -e "\nGuess the secret number between 1 and 1000:"
  else
    #if [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
    #then
    #  echo -e "\nThat is not an integer; guess again:"
    if [[ $GUESSED_NUMBER -gt $NUMBER_TO_GUESS ]]
    then
      echo -e "\nIt's lower than that, guess again:"
    elif [[ $GUESSED_NUMBER -lt $NUMBER_TO_GUESS ]]
    then
      echo -e "\nIt's higher than that, guess again:"
    fi 
  fi
  read GUESSED_NUMBER
  while [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
  do
    echo -e "\nThat is not an integer, guess again:"
    read GUESSED_NUMBER
  done
  GUESSES=$(( $GUESSES +1 ))
done
echo -e "\nYou guessed it in $GUESSES tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
GAME_INSERT=$($PSQL "INSERT INTO games(user_id, game_number, guesses) VALUES($USER_ID, $GAME_NUMBER, $GUESSES)")
}


GUESSING_GAME

