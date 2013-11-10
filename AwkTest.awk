BEGIN{  print "-START-"}
{
  #
  # Baby-Cron
  # checks 'Starting' 
  #
  if (match($1, "NOTICE") && match ($6, "Baby-Cron") && match($8, "Starting")){
       print "Baby-Cron : SUCCESS"
  }
   
  #
  # Watch-Puppy   
  # checks 'Starting' 
  #
  if (match($1, "NOTICE") && match ($6, "Watch-Puppy") && match($8, "Starting")){
       print "Watch-Puppy : SUCCESS"
  }
 	
  #
  # Updater
  # Checks Updater 'success' or 'System is up to date'
  #  
  if (match($1, "NOTICE") && match ($6, "Updater") && (match ($8$9$10$11$12, "Systemisuptodate") || match ($8$9, "Update success"))){
       print "Updater : SUCCESS"
  }
   
}
END{    print "-END-"}
