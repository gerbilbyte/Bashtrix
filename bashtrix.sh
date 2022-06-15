#!/bin/bash

# Bashtrix v2.1 
# Author: gerbil
#
# Matrix scroller written in bash especially for the Telford Makerspace (telfordmakerspace.org.uk). 
# Loads can be modified and made better.
# Also, there is a "div by zero" on small terminals that I can't be bothered to fix right now so use in a full screen.
# Feel free to fix this for me.
# 
# This script has been developed and successfully run using bash v5.0.17 on Ubuntu 20.04.
# I ncurses may need to be installed fot tput but not sure.

trap "stty echo; tput cvvis" EXIT  #Turns on local echo if script is exited/ended.

stty -echo #Turns off local echo so key press control chars aren't seen.
tput civis #turns cursor off

RED="\033[1;31m"
BLUE="\033[0;34m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;97m"
LIGHTGREY="\033[0;37m"
GREY="\033[0;90m"
BLACK="\033[0;30m"
BLANK="\033[0m"

#Get camera coords (midpoint of terminal)...
X=$((${COLUMNS}/2))
Y=$((${LINES}/2))
Z=${Y} #Lets use Y for no reason whatsoever

speed=1
delay=0

declare -A points

function addpoint {
    idx=$1
    char=$2
    colour=$3
    x=$4
    y=$5
    z=$6
    points[${idx},"X"]=${x}
    points[${idx},"Y"]=${y}
    points[${idx},"Z"]=${z}
    points[${idx},"rotX"]=0
    points[${idx},"rotY"]=0
    points[${idx},"rotZ"]=0
    points[${idx},"scrX"]=0
    points[${idx},"scrY"]=0
    points[${idx},"char"]=${char}
    [[ z -gt 0 ]] && { points[${idx},"colour"]=${GREY}; points[${idx},"trail"]=${BLACK}; } || { points[${idx},"colour"]=${WHITE}; points[${idx},"trail"]=${GREY}; }
    rotate ${idx} 0 0 0
}

function rotate {
    idx=$1
    rotx=$2
    roty=$3
    rotz=$4
    xold=0.0; yold=0.0; zold=0.0
    xnew=0.0; ynew=0.0; znew=0.0
    
    # store the new degrees
    points[${idx},"rotX"]=$( perl -e "print (${rotx} % 360.0)" )
    points[${idx},"rotY"]=$( perl -e "print (${roty} % 360.0)" )
    points[${idx},"rotZ"]=$( perl -e "print (${rotz} % 360.0)" )
    
    xold=${points[${idx},"X"]}
    yold=${points[${idx},"Y"]}
    zold=${points[${idx},"Z"]}
    
    # X rotation
    ynew=$( perl -e "print ( (${yold} * cos(${rotx}) ) + (${zold} * sin(${rotx})) )" )
    znew=$( perl -e "print ( (${zold} * cos(${rotx}) ) - (${yold} * sin(${rotx})) )" )
   	xold=${xold}
    yold=${ynew}
    zold=${znew}
    
    # Y rotation
    xnew=$( perl -e "print ( (${xold} * cos(${roty})) + (${zold} * sin(${roty})) )" )
    znew=$( perl -e "print ( (${xold} * sin(${roty})) - (${zold} * cos(${roty})) )" )
   	xold=${xnew}
    yold=${yold}
    zold=${znew}
    
    # Z rotation
    xnew=$( perl -e "print ( (${xold} * cos(${rotz})) - (${yold} * sin(${rotz})) )" )
    ynew=$( perl -e "print ( (${xold} * sin(${rotz})) + (${yold} * cos(${rotz})) )" )
    
    # Terminal X Y Position
    points[${idx},"scrX"]=$( perl -e "print int(( ${Z} * ( ${xnew} / ( ${znew} + ${Z}) ) ) + ${X} )" )
    points[${idx},"scrY"]=$( perl -e "print int(( ${Z} * ( ${ynew} / ( ${znew} + ${Z}) ) ) + ${Y} )" )
}


function translate {
    #This function "moves object by N amount, not TO amount".
    idx=$1
    tx=$2
    ty=$3
    tz=$4
    ((points[${idx},"X"]+=${tx}))
    ((points[${idx},"Y"]+=${ty}))
    ((points[${idx},"Z"]+=${tz}))
#    echo "YOOHOO: $(( ${points[${idx},"Z"]} + ${Z}))"
    points[${idx},"scrX"]=$( perl -e "print int(( ${Z} * ( ${points[${idx},"X"]} / ( ${points[${idx},"Z"]} + ${Z}) ) ) + ${X} )" )
    points[${idx},"scrY"]=$( perl -e "print int(( ${Z} * ( ${points[${idx},"Y"]} / ( ${points[${idx},"Z"]} + ${Z}) ) ) + ${Y} )" )
}

function moveto {
    #This function "moves object TO value".
    idx=$1
    newx=$2
    newy=$3
    newz=$4
    [[ newz -gt 0 ]] && { points[${idx},"colour"]=${GREY}; points[${idx},"trail"]=${BLACK}; } || { points[${idx},"colour"]=${WHITE}; points[${idx},"trail"]=${LIGHTGREY}; }

    ((points[${idx},"X"]=${newx}))
    ((points[${idx},"Y"]=${newy}))
    ((points[${idx},"Z"]=${newz}))
    points[${idx},"scrX"]=$( perl -e "print int(( ${Z} * ( ${points[${idx},"X"]} / ( ${points[${idx},"Z"]} + ${Z}) ) ) + ${X} )" )
    points[${idx},"scrY"]=$( perl -e "print int(( ${Z} * ( ${points[${idx},"Y"]} / ( ${points[${idx},"Z"]} + ${Z}) ) ) + ${Y} )" )
}

echo -ne "\033[2J" #clear screen and reset cursor to 0,0  

#build "cube"
#size=5
#addpoint 1 A ${RED} -${size} -${size} ${size}
#addpoint 2 B ${RED} -${size} ${size} ${size}
#addpoint 3 C ${RED} ${size} ${size} ${size}
#addpoint 4 D ${RED} ${size} -${size} ${size}
#addpoint 5 E ${RED} -${size} -${size} -${size}
#addpoint 6 F ${RED} -${size} ${size} -${size}
#addpoint 7 G ${RED} ${size} ${size} -${size}
#addpoint 8 H ${RED} ${size} -${size} -${size}


#build "gerbilbyteTMS" - next three lines of code need to be more elegant to prevent "div by zero" error on small "default" (80/24) terminals.
#I'm sure this is why the "doubling letters" problem has also come about (but I like it - it's a "happy error"), but that's just a guess as I cba fixing it.
#For more information speak to gerbil.  
xlength=180 #$((${COLUMNS}-20)) #180 #180
zlength=30 #$((${LINES}-30)) #40 #40
ytop=-20 #$((${LINES}/3)) #-20
characters="gerbilByteTelfordMakerSpaceX!#"
charlen=${#characters}
for i in $( seq 0 $((${charlen}-1)) ); do
    char=${characters:${i}:1}
    addpoint $((${i}+1)) "${char}" ${LIGHTGREY} $(( ${RANDOM} % ${xlength} - $((${xlength}/2)) )) ${ytop} $(( ${RANDOM} % ${zlength} - $((${zlength}/2)) ))
done

#Overwrite some of the characters with words...
points[28,"char"]="TMS"
points[29,"char"]="gerbil"

#Main bit...
for i in $( seq 0 720 ); do #yes, make this line a bit more automated, like an infinite loop with counter 1-360 that resets, and also do something about horizontal edge clipping in this section
    for j in $( seq 1 ${charlen} ); do
        #overwrite last printed char with "trail" char
        [[ ${points[${j},scrY]} -gt 0 && ${points[${j},scrY]} -lt ${LINES} ]] && echo -ne "\033[$((${points[${j},scrY]}));$((${points[${j},scrX]}))H${points[${j},trail]}${points[${j},char]}" #[Row; Col]
        #"move" the character down a space       
        translate ${j} 0 ${speed} 0
        #print the "current" char
        [[ ${points[${j},scrY]} -gt 0 && ${points[${j},scrY]} -lt ${LINES} ]] && echo -ne "\033[$((${points[${j},scrY]}));$((${points[${j},scrX]}))H${points[${j},colour]}${points[${j},char]}" #[Row; Col]    
        #When the bottom has been reached
        [[ ${points[${j},scrY]} -gt ${LINES} ]] && moveto ${j} $(( ${RANDOM} % ${xlength} - $((${xlength}/2)) )) ${ytop} $(( ${RANDOM} % ${zlength} - $((${zlength}/2)) ))
    done 
    sleep ${delay}
done
