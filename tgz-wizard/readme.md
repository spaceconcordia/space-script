## tgzWizard -> tgzWizard-vx.sh :

    Description :
      - Operates on 1 log file at a time.
      - Extracts the first n lines from the file, removes those lines from the log file.
      - If the log file has no more line, deletes it.
      - Creates a TGZ file containing the previousily extracted data and splits it into parts if needed.
      
      - should be run on all files present in the CS1_LOGS directory (schedule!)


## build_coreutils.sh :
    
    Description :
        - Downloads and builds coreutils for the Q6 (we needed the to compile the 'split' command.

## cross_compile_coreutils.sh :
        - performs the ./configure step, assuming the ./bootstrap has been run already. Then you can 'make'.

## utlQ6.tgz :
        - Collection of pre-compiled binaries from coreutils (microblaze).
