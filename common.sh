#!/usr/bin/bash

COLOR_WHITE=97
COLOR_RED=31
COLOR_GREEN=32
COLOR_YELLOW=33
COLOR_BLUE=34

STYLE_NORMAL=0
STYLE_BOLD=1

TTY=`tty`

color_text ()
{
	local text=$1
	local color=$2
	local style=${3:-0}
	
	echo -ne "\e[${style};${color}m${text}\e[0m"
}

loading_indicator ()
{
	local pid=$1
	local hint=$2
	
	# Hide cursor
	echo -en "\e[?25l" >&2

	local i=1
	
	while kill -0 "$pid" 2> /dev/null
	do
		# Calculate current offset
		i=$(( (i+1) % 4 ))
		
		# Move cursor to the beginning of line
		echo -en "\r"
		
		# Print the hint
		if [ -n "$hint" ]; then
			echo -en "$(color_text "$hint" $COLOR_BLUE $STYLE_BOLD)"
		fi
		
 		if (( i > 0 )); then
 			local indicator=$(printf '%*s' $i | tr ' ' '.')
 			echo -en $(color_text "$indicator" $COLOR_BLUE $STYLE_BOLD)
 		fi
		
		# Erase to the end of line
		echo -en "\E[K\r"
		
		# Sleep
		sleep 0.2
	done >&2 
	
	# Clear line
	echo -en "\r\E[K" >&2
	
	# Turn on cursor
	echo -en "\E[?25h" >&2
}


# 		# Move cursor to the beggining and print indicator
# 		printf "\r${spin:$i:1}"
# 		
# 		# Print the hint
# 		if [ -n "$hint" ]; then
# 			echo -n $(color_text " ($hint)" $COLOR_BLUE $STYLE_BOLD)
# 		fi

warning ()
{
    echo $(color_text "WARNING: $*" $COLOR_YELLOW $STYLE_BOLD) >&2; 
}

debug ()
{
    echo $(color_text "DEBUG: $*" $COLOR_YELLOW) >&2; 
}

info ()
{
    echo $(color_text "$*" $COLOR_BLUE $STYLE_BOLD) >&2; 
}

error ()
{ 
    echo $(color_text "ERROR: $*" $COLOR_RED $STYLE_BOLD) >&2; 
}

error_exit ()
{ 
    error $@
    exit 1
}

read_with_default ()
{
    local prompt=$1
    local default=$2
    
    local value

    read -p "$prompt [$default] " value < "$TTY"
    test -n "$value" || value="$default"
    
    echo -n "$value"
}

confirm ()
{
	local prompt=$1
	local default=${2:-y}
	
	while true; do
		local confirmation=`read_with_default "$prompt" "$default"`
		[[ "$confirmation" =~ ^(y|n)$ ]] && break
		error "Incorrect input '$confirmation'. Please input 'y' or 'n'."
	done
	
	return `[ "$confirmation" = "y" ]`;
}

get_option ()
{
    local option=$1
    local caption=$2
    local default=$3

    local value

    if [ -f $CONFIG_FILE ] && grep "$option=" $CONFIG_FILE > /dev/null; then
                value=`grep "${option}=" $CONFIG_FILE | cut -f 2 -d '='`
    else
                value=`read_with_default "Please specify $caption" "$default"`
                echo "$option=$value" >> $CONFIG_FILE
    fi

    echo $value
}

require_command ()
{
    local command=$1
    command -v $command > /dev/null 2>&1 || 
	error_exit "Required command '$command' is not found. Please install it first."
}

quoted_args ()
{
    for arg; do
	printf "%q " "$arg"
    done
}

trim ()
{
	sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

# Escape bash string
escape ()
{
	sed -e 's/["\\]/\\&/g'
}

# Escape regex expression
regex_escape ()
{
	sed -e 's/[]\/$*.^|[]/\\&/g'
}

process_patterns ()
{
	local -a sed_args
	local pattern
	for pattern; do
		local from=$(regex_escape <<< "${pattern%%=*}")
		local to=$(regex_escape <<< "${pattern#*=}")
		sed_args+=(-e "s/$from/$to/g")
	done
	
	sed "${sed_args[@]}"
}
