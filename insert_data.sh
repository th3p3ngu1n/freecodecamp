#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
    then
      # insert into teams table
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
      if [[ -z $TEAM_ID ]]
        then
          TEAM_INSERT_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER')")
          echo "Inserting winner into teams: $WINNER"
          if [[ $TEAM_INSERT_RESULT == 'INSERT 0 1' ]]
            then
            WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
          fi
      else WINNER_ID=$TEAM_ID
      fi # winner insertion
      
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
      if [[ -z $TEAM_ID ]]
        then
          TEAM_INSERT_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT')")
          echo "Inserting opponent into teams: $OPPONENT"
          if [[ $TEAM_INSERT_RESULT == 'INSERT 0 1' ]]
            then
            OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
          fi
      else OPPONENT_ID=$TEAM_ID
      fi # opponent insertion

      # insert into games table
      GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year = $YEAR AND round = '$ROUND' AND winner_id = $WINNER_ID AND opponent_id = $OPPONENT_ID AND winner_goals = $WINNER_GOALS AND opponent_goals = $OPPONENT_GOALS")
      if [[ -z $GAME_ID ]]
        then
        GAME_ID=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
        echo "Inserting into games: $YEAR $WINNER $OPPONENT"
      fi # insert into goals
      
  fi # year check
done
