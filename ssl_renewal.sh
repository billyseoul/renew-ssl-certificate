#!/bin/bash

printf "\n>>> Would you like to renew your SSL certificate?\nType [y,n]>> "
read choice

answer_choice () {
    if [[ $choice == "y" ]]
    then
        printf "\n### Renewing the SSL Certificate ###\n"
        sleep 1
    elif [[ $choice == "n" ]]
    then
        printf "\n### You answered no. Exiting program ###"
        exit
        fi
        # Typing "y" will run the rest of the program. Typing "n" will terminate the program
}

rename_old () {
    printf "\n### Renaming old .pem file in the directory path ###\n"
    sleep 1
    cd /destination/of/old/certificate
    for cert in *.pem
    do
        oldcert="${cert}.old"
        mv "$cert" "$oldcert"
        mv $oldcert /path/to/expired/certificates/directory
    done
    # The expiring certificate that is being replaced in the following directory path will append a ".old" extension to the end of the file
    # It will be moved to a directory archive of previously replaced certificates the admin may have created in order to revert just in case. 
}

rename_new () {
    while true;
    do
        printf "\n>>> Input the naming convention of your new SSL certificate\nNew SSL Certificate Name >> "
        read newssl
        printf "\n >>> You typed the following below:\n <$newssl> \n>>> Type "y" to confirm or "n" if an error was made and you need to rename the file\n[y,n]>>"
        read userchoice
            if [[ $userchoice == "y" ]]
            then
                cd /path/to/new/certificate/directory
                printf "### Merging the public & private keys into $newssl and moving the file over to the specified path in the script ###\n"
                sleep 2
                cat public.pem private.pem > $newssl
                mv $newssl /path/to/new/certificate/directory
                chcon <selinux fcontext of the destination directory> $newssl
                break
            elif [[ $userchoice == "n" ]]
            then
                rm -f $newssl
                continue
            fi
    done
    # The user inputs "y" and will allow that person to name the certificate they'll replace the old one with. 
    # It'll concatenate public and private keys to the newssl variable, change the selinux context, and move it to the directory path specified in the script.
    # If the user inputs "n" for naming the new certificate incorrectly, the program will loop back to the beginning of the rename_new function
    # so the user can try again.
}

restart_service () {
    printf "Reloading the httpd server\n"
    sleep 1
    systemctl reload httpd
    systemctl status httpd
    ls -l /path/of/new/certificate/*.pem
    printf "*** Your SSL certificate has been renewed. Verify by going to your webpage and clicking the certificate icon. Goodbye! ***\n"
    # Reloads the apache server. The user can double check it was renewed by visiting the webpage they renewed the certificate on.
}

answer_choice
rename_old
rename_new
restart_service
