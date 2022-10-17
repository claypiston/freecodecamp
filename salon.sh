#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ My Salon ~~~~\n"

MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nHow can I help you?"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_NUMBER BAR SERVICE
  do
    echo -e "$SERVICE_NUMBER) $SERVICE"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please enter a number!"
  else
    # get service id
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # if service id not exists
    if [[ -z $SERVICE_ID ]]
    then
      MAIN_MENU "Please enter a valid number!"
    else
      # enter phone number
      echo -e "\nPlease enter your phone number!"
      read CUSTOMER_PHONE
      # check if customer
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # if not add new customer
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nPlease enter your name!"
        read CUSTOMER_NAME
        CUSTOMER_ADD=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
    
      echo -e "\nPlease select a time for your appointment!"
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      APPOINTMENT_INSERT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
      if [[ $APPOINTMENT_INSERT = "INSERT 0 1" ]]
      then
        SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID")
        echo "I have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi
  fi
}

EXIT () {
  echo -e "\nExit"
}

MAIN_MENU
