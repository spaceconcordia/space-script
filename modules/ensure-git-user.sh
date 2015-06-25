#!/bin/bash
emailregex='[a-z0-9!#$%&'"'"'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"'"'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?'
emailregex2="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$"

if [ ! -s "~/.gitconfig" ]; then
    email=""
    until [[ "$email" =~ "$emailregex" ]]; 
    do
        read -r -p "Please enter a valid email address registered with Github: " email
        echo $email
    done
    git config --global user.email "$email"

    name=""
    until [ "$name" != "" ]; 
    do
        read -r -p "Please enter your name: " name
    done
    git config --global user.name "$name"
fi
mv $HOME/.gitconfig /tmp/
ln -s /tmp/.gitconfig $HOME/.gitconfig
