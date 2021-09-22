//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
/*    {"  ", "uname -r", 360, 0}, */

    {" ﬙ ", "top -bn 1 | awk '/^%Cpu/ {print int($2 + $4 + $6)\"%\"}'", 3,   0},

	{" ", "free -h | awk '/^Mem/ { print $3 }' | sed s/i//g",	3,		0},

    {" ", "df -h / | awk 'NR==2 { print $4 }' | sed s/i//g", 3, 0},
    
    {" ", "pacman -Q | wc -l", 5, 0},

	{" ", "date '+%b %d-%Y'",					360,		0},

	{" ", "date '+%I:%M:%S %p'",					1,		0},
    
    {"", "uptime --pretty | sed -e 's/up //g' -e 's/ days/d/g' -e 's/ day/d/g' -e 's/ hours/h/g' -e 's/ hour/h/g' -e 's/ minutes/m/g' -e 's/, / /g'", 30,   0},

};

//sets delimeter between status commands. NULL character ('\0') means no delimeter.
static char delim[] = " | ";
static unsigned int delimLen = 5;
