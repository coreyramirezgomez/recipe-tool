#!/bin/bash
#### Non-Customizable Header ####
# BASH_BOILER_VERSION=2019.07.02.01
# Generated with Bash-Boiler on 07-02-19_16:23:49
# Use updater to update this script:
# https://github.com/coreyramirezgomez/Bash-Boiler.git
# Modifying any content between blocks like the following:
# "#### Non-Customizable ... #####"
# ....
# "#### ####"
# will be overwritten by Bash-Boiler updater function.
trap catch_exit $?
#### ####

#### Custom Header ####
#### ####

#### Non-Customizable Global Variables ####
QUIET=""
START_TIME=$(date +%s)
START_DATE="$(date +%m-%d-%y_%H:%M:%S)"
VERBOSE=""
BINARIES_MISSING=()
#### ####

#### Customizable Variables ####
ARGS_REQUIRED=1
BINARIES_OPTIONAL=()
BINARIES_REQUIRED=( "autopkg" )
GARBAGE_COLLECTOR=0
GARBAGE=()
DEBUG=0
FORCE_FLAG=0
WORK_DIR="$(pwd)" # Only variable not in alphabetical order because LOG_FILE depends on it.
LOG_FILE="$WORK_DIR/""$(basename $0).log"
LOGGING=0
#### ####

#### Custom Variables ####
INFO=0
OVERRIDE_DIR="$HOME/Library/AutoPkg/RecipeRepos/"
SELECT=0
TRUST=0
VERIFY=0
RECIPE_NAMES=()
#### ####

#### Non-Customizable Functions ####
backup_file()
{
	case $# in
		0) fail_notice_exit "(${FUNCNAME[0]}) No Arguments provided." 101 ;;
		1)
			backup_target="$1"
			debug_print -e -Y -S "(${FUNCNAME[0]}) No backup destination specified."
			backup_dest="$1-backup-$(date +%m-%d-%y_%H:%M:%S)"
			debug_print -e -Y -S "(${FUNCNAME[0]}) Using default: $backup_dest"
			;;
		2)
			backup_target="$1"
			backup_dest="$2"
			;;
		*)
			debug_print -e -Y -S "(${FUNCNAME[0]}) More that 2 arguments provided: $*"
			debug_print -e -Y -S "(${FUNCNAME[0]}) Only using first 2."
			backup_target="$1"
			backup_dest="$2"
			;;
	esac

	if [ ! -f "$backup_target" ]; then
		local_print -R -S "(${FUNCNAME[0]}) No file to backup @ $backup_target"
		return 1
	fi
	if	[ -d "$backup_dest" ]; then
		local_print -R -S "(${FUNCNAME[0]}) Backup destination is a directory: $backup_dest"
		return 1
	fi
	if [ -f "$backup_dest" ]; then
		local_print -Y -S "(${FUNCNAME[0]}) File already exists @ $backup_dest"
		get_response "(${FUNCNAME[0]}) Would you like to backup $backup_dest?"
		[ $? -eq 1 ] && return 1
		backup_file "$backup_dest"
		[ $? -ne 0 ] && return 1
	fi
	cp -f"$VERBOSE" -- "$backup_target" "$backup_dest"
	[ $? -ne 0 ] && fail_notice_exit "(${FUNCNAME[0]}) Backup failure for $backup_target" $?
	debug_print -e -B -S "Successfully created backup of $backup_target to $backup_dest"
	return 0
}
catch_exit()
{
	code=$?
	debug_print -e -B -S "START DATE: $START_DATE"
	debug_print -e -B -S "END DATE: $(date +%m-%d-%y_%H:%M:%S)"
	debug_print -e -B -S "$0 ran for  $(( $(date +%s) - $START_TIME ))s"
	case $code in
			# Exit codes from https://www.tldp.org/LDP/abs/html/exitcodes.html
		0) debug_print -e -G -S "Successful Exit: $code" ;;
		1) debug_print -e -R -S "General Fatal Exit: $code " ;;
		2) debug_print -e -R -S "Misuse of shell builtins: $code" ;;
		126) debug_print -e -R -S "Command invoked cannot execute: $code" ;;
		127) debug_print -e -R -S "Command not found: $code" ;;
		128) debug_print -e -R -S "Invalid argument to exit: $code" ;;
		129|13[0-9]|14[0-9]|15[0-9]|16[0-5])debug_print -e -R -S "Fatal error signal: $code" ;;
		130) debug_print -e -Y -S "Script terminated by Control-C: $code" ;;
			# Custom exit codes
		100) debug_print -e -Y -S "Unspecified error: $code" ;;
		101) debug_print -e -R -S "Missing required variable or argument: $code" ;;
		*) debug_print -e -Y -S "Unknown exit: $code" ;;
	esac
	catch_exit_custom "$?"
	if [ $GARBAGE_COLLECTOR -eq 1 ]; then
		for t in "${GARBAGE[@]}"
		do
			garbage_dump "$t"
		done
	fi
	debug_print -e -B -S "======= End of Run for $0 ======="
}
check_binaries()
{
	debug_print -e -B -S "(${FUNCNAME[0]}) PATH=$PATH"
	if [ $# -lt 1 ];then
		debug_print -e -Y -S "(${FUNCNAME[0]}) No binary package list to check."
		return 0
	fi
	missing=0
	arr=("$@")
	debug_print -e -B -S "(${FUNCNAME[0]}) Received binary package list: ${arr[*]}"
	for p in "${arr[@]}"
	do
		if which "$p"  >&/dev/null; then
			debug_print -e -G -S "(${FUNCNAME[0]}) Found $p"
		else
			debug_print -e -Y -S "(${FUNCNAME[0]}) Missing binary package: $p"
			BINARIES_MISSING=( "${BINARIES_MISSING[@]}" "$p" )
			((missing++))
		fi
	done
	return $missing
}
garbage_add()
{
	[ $# -lt 1 ] && fail_notice_exit "(${FUNCNAME[0]}) No arguments received." 101
	for a in "$@"
	do
		debug_print -e -B -S "(${FUNCNAME[0]}) Adding to GARBAGE pile: $a"
		GARBAGE=( "${GARBAGE[@]}" "$a" )
	done
	return 0
}
garbage_dump()
{
	[ $# -lt 1 ] && fail_notice_exit "(${FUNCNAME[0]}) No arguments received." 101
	for i in "$@"
	do
		if [ -f "$i" ];then
			debug_print -e -Y -S "(${FUNCNAME[0]}) Removing file: $i"
			rm -f"$VERBOSE" "$i"
			return_code=$?
		elif [ -d "$i" ];then
			debug_print -e -Y -S "(${FUNCNAME[0]}) Removing directory: $i"
			rm -rf"$VERBOSE" "$i"
			return_code=$?
		else
			debug_print -e -R -S "(${FUNCNAME[0]}) $i doesn't exist."
			return_code=0
		fi
	done
	return $return_code
}
debug_state()
{
	debug_print -e -B -S "(${FUNCNAME[0]}) Current Template Variable State: "
	debug_print -e -B -S "(${FUNCNAME[0]}) WORK_DIR: $WORK_DIR"
	debug_print -e -B -S "(${FUNCNAME[0]}) FORCE_FLAG: $(var_state $FORCE_FLAG)"
	debug_print -e -B -S "(${FUNCNAME[0]}) DEBUG: $(var_state $DEBUG)"
	debug_print -e -B -S "(${FUNCNAME[0]}) VERBOSE: $VERBOSE"
	debug_print -e -B -S "(${FUNCNAME[0]}) QUIET: $QUIET"
	debug_print -e -B -S "(${FUNCNAME[0]}) START_DATE: $START_DATE"
	debug_print -e -B -S "(${FUNCNAME[0]}) START_TIME: $START_TIME"
	debug_print -e -B -S "(${FUNCNAME[0]}) LOG_FILE: $LOG_FILE"
	debug_print -e -B -S "(${FUNCNAME[0]}) LOGGING: $(var_state $LOGGING)"
	debug_print -e -B -S "(${FUNCNAME[0]}) BINARIES_REQUIRED: ${BINARIES_REQUIRED[*]}"
	debug_print -e -B -S "(${FUNCNAME[0]}) BINARIES_OPTIONAL: ${BINARIES_OPTIONAL[*]}"
	debug_state_custom
}
fail_notice_exit()
{
	if [ $# -eq 0 ]; then
		desc="Unknown"
		error_code=100
	elif [ $# -eq 1 ]; then
		desc="$1"
		error_code=100
	elif [ $# -gt 2 ]; then
		debug_print -e -Y "(${FUNCNAME[0]}) Received more than 2 required args: $*"
		desc="$1"
		error_code="$2"
	else
		desc="$1"
		error_code="$2"
	fi
	local_print -e -R -S "Failure: $desc"
	exit $error_code
}
get_response()
{
	[ $# -lt 1 ] && fail_notice_exit "(${FUNCNAME[0]}) Missing question argument." 101
	debug_print -e -B -S "(${FUNCNAME[0]}) Received question: $1"
	reply=""
	[ $FORCE_FLAG -eq 1 ] && reply="y"
	while :
	do
		case "$reply" in
			"N" | "n")
				debug_print -e -B -S "(${FUNCNAME[0]}) Returning $reply (1) reply."
				return 1
				;;
			"Y" | "y")
				debug_print -e -B -S "(${FUNCNAME[0]}) Returning $reply (0) reply."
				return 0
				;;
			*)
				local_print -e -Y -n "$1 (Y/N): "
				read -n 1 reply
				echo ""
				debug_print -e -B -S "(${FUNCNAME[0]}) Question answered with: $reply"
				;;
		esac
	done
}
local_print()
{
	if [ $LOGGING -eq 1 ]; then
		cprint -e -l "$LOG_FILE" "$@"
		return 0
	else
		cprint -e "$@"
		return 0
	fi
}
debug_print()
{
	if [ $LOGGING -eq 1 ]; then
		cprint -e -l "$LOG_FILE" "$@"
		return 0
	elif [ $DEBUG -eq 1 ]; then
		cprint -e "$@"
		return 0
	fi
}
main()
{
	[ $DEBUG -eq 1 ] && VERBOSE="v"
	[ $DEBUG -eq 0 ] && QUIET="q"
	if [ $LOGGING -eq 1 ] && [ ! -f "$LOG_FILE" ]; then
		touch "$LOG_FILE"
		debug_print -e -B -S "(${FUNCNAME[0]}) Created Log File: $LOG_FILE @ $START_DATE" -l "$LOG_FILE"
	fi
	debug_state
	check_binaries "${BINARIES_REQUIRED[@]}"
	return_code=$?
	[ $return_code -ne 0 ] && fail_notice_exit "(${FUNCNAME[0]}) Missing $return_code required binaries." 101
	check_binaries "${BINARIES_OPTIONAL[@]}"
	return_code=$?
	[ $return_code -ne 0 ] && debug_print -Y -S "(${FUNCNAME[0]}) Missing $return_code optional binaries."
	[ ${#BINARIES_MISSING[@]} -gt 0 ] && debug_print -Y -S "(${FUNCNAME[0]}) Missing the following binaries: ${BINARIES_MISSING[*]}"
	main_custom
}
parse_args()
{
	EXTRA_ARGS=()
	while [ ${#} -gt 0 ]; do
		case "${1}" in
			"--help" | "-h") usage ;;
			"--debug") DEBUG=$(var_toggle $DEBUG) ;;
			"--force" | "-f") FORCE_FLAG=$(var_toggle $FORCE_FLAG) ;;
			"--garbage-collect") GARBAGE_COLLECTOR=$(var_toggle $GARBAGE_COLLECTOR) ;;
			"--logging"| "-l") LOGGING=$(var_toggle $LOGGING) ;;
			"--logfile")
				[ -d "$2" ] && fail_notice_exit "(${FUNCNAME[0]}) Invalid logfile, it is a directory: $2"
				LOG_FILE="$2"
				shift
				;;
			"--work_dir")
				[ ! -d "$2" ] && fail_notice_exit "(${FUNCNAME[0]}) Invalid directory: $2"
				WORK_DIR="$2"
				shift
				;;
			*)
				debug_print -B "(${FUNCNAME[0]}) Extra Arg Received ($1), saving for custom parser."
				EXTRA_ARGS=( "${EXTRA_ARGS[@]}" "$1" )
				;;
		esac
		shift 1
	done
	parse_args_custom "${EXTRA_ARGS[@]}"
}
usage()
{
	echo ""
	echo "Usage for $0:"
	echo ""
	echo -n "	--garbage-collect: Toggle garbage-collect flag. Removes all files/directory variables in GARBAGE array. Default: "
	[ $GARBAGE_COLLECTOR -eq 0 ] && local_print -R "$(var_state $GARBAGE_COLLECTOR)"
	[ $GARBAGE_COLLECTOR -eq 1 ] && local_print -G "$(var_state $GARBAGE_COLLECTOR)"
	echo -n "	--debug: Toggle Debugging. Default: "
	[ $DEBUG -eq 0 ] && local_print -R "$(var_state $DEBUG)"
	[ $DEBUG -eq 1 ] && local_print -G "$(var_state $DEBUG)"
	echo -n "	--force: Answer 'yes'/'y' to all questions. (aka force) Default: "
	[ $FORCE_FLAG -eq 0 ] && local_print -R "$(var_state $FORCE_FLAG)"
	[ $FORCE_FLAG -eq 1 ] && local_print -G "$(var_state $FORCE_FLAG)"
	echo "	[--help|-h]: Display this dialog"
	echo -n "	[--logging|-l]: Toggle logging. Default: "
	[ $LOGGING -eq 0 ] && local_print -R "$(var_state $LOGGING)"
	[ $LOGGING -eq 1 ] && local_print -G "$(var_state $LOGGING)"
	echo "	--logfile filename: Specifiy the logfile output. Default: $LOG_FILE"
	usage_custom
	echo ""
	exit 0
}
var_state()
{
	case $1 in
		0) echo "OFF" ;;
		1) echo "ON" ;;
		*) echo "Unknown ($1)"
	esac
}
var_toggle()
{
	case $1 in
		[0-1]) echo $(( (($1 + 1 )) % 2 )) ;;
		*) fail_notice_exit "(${FUNCNAME[0]}) Can't toggle: $1"
	esac
}
#### ####

#### Non-Customizable External Template Functions ####

cprint()
{
	CPRINT_process_nl()
	{
		if [ -z ${CPRINT_NL} ]; then
			[ ! -z ${CPRINT_ERR_OUT} ] && (>&2 echo "") || echo ""
		fi
	}
	CPRINT_process_prenl()
	{
		if [ ! -z ${PCPRINT_NL} ]; then
			while [ $PCPRINT_NL -gt 0 ]
			do
				[ ! -z ${CPRINT_ERR_OUT} ] && (>&2 echo "") || echo ""
				[ ! -z ${CPRINT_LOG_CPRINT_STYLED} ] && echo ""  >> "$CPRINT_LOG_CPRINT_STYLED"
				[ ! -z ${CPRINT_LOG} ] && echo ""  >> "$CPRINT_LOG"
				((PCPRINT_NL--))
			done
		fi
	}
	CPRINT_process_string()
	{
		[ -z "${CPRINT_STRING}" ] && CPRINT_STRING=""
		[ ! -z ${CPRINT_LOG} ] && echo "$CPRINT_STRING" >> "$CPRINT_LOG"
		[ -z ${CPRINT_POS} ] && CPRINT_POS=0 # Position is not set, so use the default.
		[ ! -z ${CPRINT_STYLE} ] && CPRINT_STRING="$($CPRINT_STYLE $CPRINT_STRING)" # Apply style
		[ -z "${CPRINT_FOREGROUND}" ] && CPRINT_FOREGROUND=""
		[ -z "${CPRINT_BACKGROUND}" ] && CPRINT_BACKGROUND=""
		RESET=$(CPRINT_translate_color_code "RESET")
		if [ -f "$(which printf 2>/dev/null)" ];then
			[ ! -z ${CPRINT_ERR_OUT} ] && (>&2 printf -- "$CPRINT_FOREGROUND$CPRINT_BACKGROUND%$CPRINT_POS"s"$RESET" "$CPRINT_STRING") || printf -- "$CPRINT_FOREGROUND$CPRINT_BACKGROUND%$CPRINT_POS"s"$RESET" "$CPRINT_STRING"
		else # printf doesn't exist
			[ ! -z ${CPRINT_ERR_OUT} ] && (>&2 echo "$CPRINT_FOREGROUND""$CPRINT_BACKGROUND""$CPRINT_STRING""$RESET") || echo "$CPRINT_FOREGROUND""$CPRINT_BACKGROUND""$CPRINT_STRING""$RESET"
		fi
		[ ! -z ${CPRINT_LOG_CPRINT_STYLED} ] && echo -e "$CPRINT_STRING" >> "$CPRINT_LOG_CPRINT_STYLED"
	}
	CPRINT_random_color()
	{
		local colors=( "BLACK" "WHITE" "RED" "YELLOW" "GREEN" "BLUE" "CYAN" "PURPLE" )
		echo "${colors[$RANDOM % ${#colors[@]}]}"
	}
	CPRINT_translate_color_code()
	{
		if [ $# -lt 1 ]; then
			echo "Missing color name."
			exit 1
		fi
		local CODE=""
		case "$1" in
			"FG"*)
				case "$1" in
					*"BLACK" ) CODE='30m' ;;
					*"WHITE" ) CODE='37m' ;;
					*"RED" ) CODE='31m' ;;
					*"YELLOW" ) CODE='33m' ;;
					*"GREEN" ) CODE='32m' ;;
					*"BLUE" ) CODE='34m' ;;
					*"CYAN" ) CODE='36m' ;;
					*"PURPLE" ) CODE='35m' ;;
				esac
				if [ ! -z ${CPRINT_BOLD} ]; then
					if [ $CPRINT_BOLD -eq 1 ]; then
						CODE='1;'$CODE
					fi
				else
					CODE='0;'$CODE
				fi
				;;
			"BG"*)
				case "$1" in
					*"BLACK" ) CODE='40m' ;;
					*"WHITE" ) CODE='47m' ;;
					*"RED" ) CODE='41m' ;;
					*"YELLOW" ) CODE='43m' ;;
					*"GREEN" ) CODE='42m' ;;
					*"BLUE" ) CODE='44m' ;;
					*"CYAN" ) CODE='46m' ;;
					*"PURPLE" ) CODE='45m' ;;
				esac
				;;
			"RESET") CODE='m' ;;
		esac
		case "$(uname -s)" in
			"Darwin") echo "\033[""$CODE" ;;
			"Linux") echo "\e[""$CODE" ;;
			*)
				echo "Unknown System: $(uname -s)"
				exit 1
				;;
		esac
	}
	CPRINT_parse_args()
	{
		while [ ${#} -gt 0 ];
		do
			case "${1}" in
				"-e" | "--stderr") CPRINT_ERR_OUT=1 ;;
				"-n" | "no-newline") CPRINT_NL=1 ;;
				"-p" | "--pre-newline")
					[ -z ${PCPRINT_NL} ] && PCPRINT_NL=0
					((PCPRINT_NL++))
					;;
				"-I" | "-b" | "--bold" ) CPRINT_BOLD=1 ;;
				"-A" | "--cowsay")
					if [ -f "$(which cowsay 2>/dev/null)" ]; then
						CPRINT_STYLE="$(which cowsay)"
					else
						(>&2 echo "Skipping $1 becasue, binary not available.")
					fi
					;;
				"-F" | "--figlet")
					if [ -f "$(which figlet 2>/dev/null)" ]; then
						CPRINT_STYLE="$(which figlet)"
					else
						(>&2 echo "Skipping $1 becasue, binary not available.")
					fi
					;;
				"--cow-file" | "--fig-file")
					if [ ! -z "${CPRINT_STYLE}" ]; then
						if [ ! -f "$2" ]; then
							(>&2 echo "Skipping $1 because, not a valid file: $2.")
						else
							CPRINT_STYLE="$CPRINT_STYLE -f $2"
						fi
					else
						(>&2 echo "Skipping $1 because, CPRINT_STYLE not set.")
					fi
					;;
				"-c" | "--centered") [ $(tput cols) -le 80 ] && CPRINT_POS=0 || CPRINT_POS=$((( $(tput cols) - 80 ) / 2 )) ;;
				"--BG" | "--bg" | "--background" | "--FG" | "--fg"| "--foreground")
					local TYPE=""
					local COLOR_CODE=""
					case "$1" in
						"--BG" | "--bg" | "--background") TYPE="BG" ;;
						"--FG" | "--fg" | "--foreground") TYPE="FG" ;;
					esac
					case "$2" in
						"black") COLOR_CODE="$(CPRINT_translate_color_code "$TYPE"'BLACK')" ;;
						"white") COLOR_CODE="$(CPRINT_translate_color_code "$TYPE"'WHITE')" ;;
						"red") COLOR_CODE="$(CPRINT_translate_color_code "$TYPE"'RED')" ;;
						"yellow") COLOR_CODE="$(CPRINT_translate_color_code "$TYPE"'YELLOW')" ;;
						"green") COLOR_CODE="$(CPRINT_translate_color_code "$TYPE"'GREEN')" ;;
						"blue") COLOR_CODE="$(CPRINT_translate_color_code "$TYPE"'BLUE')" ;;
						"cyan") COLOR_CODE="$(CPRINT_translate_color_code "$TYPE"'CYAN')" ;;
						"purple") COLOR_CODE="$(CPRINT_translate_color_code "$TYPE"'PURPLE')" ;;
						"random") COLOR_CODE="$(CPRINT_translate_color_code "$TYPE""$(CPRINT_random_color)")" ;;
						"*")
							(>&2 echo "Unrecognized Arguement: $2")
							exit 1
							;;
					esac
					case "$1" in
						"--BG" | "--bg" | "--background") CPRINT_BACKGROUND="$COLOR_CODE" ;;
						"--FG" | "--fg" | "--foreground") CPRINT_FOREGROUND="$COLOR_CODE" ;;
					esac
					shift
					;;
				"-K" | "--black") CPRINT_FOREGROUND="$(CPRINT_translate_color_code 'FGBLACK')" ;;
				"-W" | "--white") CPRINT_FOREGROUND="$(CPRINT_translate_color_code 'FGWHITE')" ;;
				"-R" | "--red") CPRINT_FOREGROUND="$(CPRINT_translate_color_code 'FGRED')" ;;
				"-Y" | "--yellow") CPRINT_FOREGROUND="$(CPRINT_translate_color_code 'FGYELLOW')" ;;
				"-G" | "--green") CPRINT_FOREGROUND="$(CPRINT_translate_color_code 'FGGREEN')" ;;
				"-B" | "--blue") CPRINT_FOREGROUND="$(CPRINT_translate_color_code 'FGBLUE')" ;;
				"-C" | "--cyan") CPRINT_FOREGROUND="$(CPRINT_translate_color_code 'FGCYAN')" ;;
				"-P" | "--purple") CPRINT_FOREGROUND="$(CPRINT_translate_color_code 'FGPURPLE')" ;;
				"-Z" | "--random") CPRINT_FOREGROUND="$(CPRINT_translate_color_code "FG$(CPRINT_random_color)")" ;;
				"-L" | "--log-styled")
					if [ -d "$2" ]; then
						echo "Specified filename is a directory: $2"
						exit 1
					fi
					CPRINT_LOG_CPRINT_STYLED="$2"
					shift
					;;
				"-l" | "--log")
					if [ -d "$2" ]; then
						echo "Specified filename is a directory: $2"
						exit 1
					fi
					CPRINT_LOG="$2"
					shift
					;;
				"-S" | "--string")
					shift
					CPRINT_STRING="$*"
					break
					;;
				*)
					CPRINT_STRING="$*"
					break
					;;
			esac
			shift 1
		done
	}
	CPRINT_parse_args "$@"
	if [ -z "${CPRINT_STRING}" ]; then
		CPRINT_STRING="$*"
	fi
	if [ ! -z "${CPRINT_STRING}" ]; then
		CPRINT_process_prenl
		CPRINT_process_string
		CPRINT_process_nl
	fi
	unset CPRINT_ERR_OUT
	unset CPRINT_NL
	unset CPRINT_PNL
	unset CPRINT_BOLD
	unset CPRINT_STYLE
	unset CPRINT_POS
	unset CPRINT_BACKGROUND
	unset CPRINT_FOREGROUND
	unset CPRINT_LOG
	unset CPRINT_LOG_STYLED
	unset CPRINT_STRING
}
#### ####

#### Customizable Functions ####
catch_exit_custom()
{
	debug_print -e -B -S "(${FUNCNAME[0]}) Started ${FUNCNAME[0]} function with args: $*"
}
get_autopkg_trust_behavior()
{
	debug_print -e -B -S "(${FUNCNAME[0]}) Started ${FUNCNAME[0]} function with args: $*"
	R=$(defaults read com.github.autopkg FAIL_RECIPES_WITHOUT_TRUST_INFO 2>/dev/null)
	if [ $? -ne 0 ]; then
		debug_print -B -S "(${FUNCNAME[0]}) Key FAIL_RECIPES_WITHOUT_TRUST_INFO not set or some other error ($?)."
		return 66
	else
		case "$R" in
			0)
				debug_print -R -S "(${FUNCNAME[0]}) FAIL_RECIPES_WITHOUT_TRUST_INFO set to False."
				return 0
				;;
			1)
				debug_print -G -S "(${FUNCNAME[0]}) FAIL_RECIPES_WITHOUT_TRUST_INFO set to True."
				return 1
				;;
			*)
				debug_print -R -S "(${FUNCNAME[0]}) FAIL_RECIPES_WITHOUT_TRUST_INFO set to Unknown value: $R."
				return 66
				;;
			esac
	fi
}
set_autopkg_trust_behavior()
{
	debug_print -e -B -S "(${FUNCNAME[0]}) Started ${FUNCNAME[0]} function with args: $*"
	[ $# -lt 1 ] && fail_notice_exit "(${FUNCNAME[0]}) Not enough arguments provided."
	case "$1" in
		0 | "true" | "yes" | "YES" | "TRUE")
			action="write"
			value="-bool YES"
			;;
		1 | "false" | "no" | "NO" | "FALSE")
			action="write"
			value="-bool NO"
			;;
		"NONE" | "none" | "RESET" | "reset")
			value=""
			action="delete"
			;;
		*)
			fail_notice_exit "(${FUNCNAME[0]}) Incorrect argument provided."
			;;
	esac
	defaults $action com.github.autopkg FAIL_RECIPES_WITHOUT_TRUST_INFO $value
	return_code=$?
	case "$return_code" in
		0) debug_print -G -S "(${FUNCNAME[0]}) Successful action $action to FAIL_RECIPES_WITHOUT_TRUST_INFO with value: $value";;
		*) debug_print -R -S "(${FUNCNAME[0]}) Failed action $action to FAIL_RECIPES_WITHOUT_TRUST_INFO with value: $value" ;;
	esac
	return $return_codes
}
debug_state_custom()
{
	debug_print -e -B -S "(${FUNCNAME[0]}) Started ${FUNCNAME[0]} function with args: $*"
	debug_print -e -B -S "(${FUNCNAME[0]}) Current Custom Variable State: "
}
main_custom()
{
	debug_print -e -B -S "(${FUNCNAME[0]}) Started ${FUNCNAME[0]} function with args: $*"

	for R in "${RECIPE_NAMES[@]}"
	do
		BLOCK="##########"
		if [ $INFO -eq 1 ]; then
			local_print -C -S "$BLOCK Info for $R $BLOCK"
			autopkg info --override-dir="$OVERRIDE_DIR" "$R"
			local_print -C -S "$BLOCK $BLOCK"
		fi
		if [ $TRUST -eq 1 ]; then
			local_print -C -S "$BLOCK Trust Action for $R $BLOCK"
			autopkg update-trust-info --override-dir="$OVERRIDE_DIR" "$R"
			[ $? -eq 0 ] && local_print -G -S "Trust Successful for $R"
			[ $? -ne 0 ] && local_print -R -S "Trust Failed for $R"
			local_print -C -S "$BLOCK $BLOCK"
		fi
		if [ $VERIFY -eq 1 ]; then
			local_print -C -S "$BLOCK Verify Action $R $BLOCK"
			autopkg verify-trust-info --override-dir="$OVERRIDE_DIR" "$R"
			local_print -C -S "$BLOCK $BLOCK"
		fi
	done
}
parse_args_custom()
{
	debug_print -e -B -S "(${FUNCNAME[0]}) Started ${FUNCNAME[0]} function with args: $*"
	while [ ${#} -gt 0 ]; do
		case "${1}" in
			"--get-trust-behavior")
				get_autopkg_trust_behavior
				case "$?" in
					0) local_print -R -S "FAIL_RECIPES_WITHOUT_TRUST_INFO = FALSE";;
					1) local_print -G -S "FAIL_RECIPES_WITHOUT_TRUST_INFO = TRUE";;
					*) local_print -Y -S "FAIL_RECIPES_WITHOUT_TRUST_INFO = NOT SET";;
				esac
				exit 0
				;;
			"--info" | "--i") INFO=$(var_toggle $INFO) ;;
			"--name" | "--n")
				RECIPE_NAMES=( "${RECIPE_NAMES[@]}" "$2")
				shift
				;;
			"--override-dir")
				[ ! -d "$2" ] && fail_notice_exit "(${FUNCNAME[0]}) Invalid override_dir, it is not a directory: $2"
				OVERRIDE_DIR="$2"
				shift
				;;
			"--select" | "--s") SELECT=$(var_toggle $SELECT) ;;
			"--set-trust-behavior-"*)
				set_autopkg_trust_behavior "$(echo $1 | cut -d '-' -f6)"
				[ $? -ne 0 ] && fail_notice_exit "Failed to set FAIL_RECIPES_WITHOUT_TRUST_INFO to $(echo $1 | cut -d '-' -f6)"
				exit 0
				;;
			"--trust" | "-t") TRUST=$(var_toggle $TRUST) ;;
			"--verify" | "-v") VERIFY=$(var_toggle $VERIFY) ;;
			*)
				debug_print -e -B -S "Processing Unknown Argument: $1"
				if [ ${#} -eq 1 ];then
					RECIPE_NAMES=( "${RECIPE_NAMES[@]}" "$1")
				else
					fail_notice_exit "(${FUNCNAME[0]}) Unknown argument: $1" 1
				fi
				;;
		esac
		shift 1
	done
	[ ! -d "$OVERRIDE_DIR" ] && fail_notice_exit "(${FUNCNAME[0]}) OVERRIDE_DIR ($OVERRIDE_DIR) does not exist."
	if [ $SELECT -eq 1 ]; then
		recipes=( $(ls "$OVERRIDE_DIR") "ALL" )
		option_selector "${recipes[@]}"
		RECIPE_NAMES=( "${RECIPE_NAMES[@]}" "${recipes[$?]}" )
	fi
	if [ ${#RECIPE_NAMES[@]} -eq  0 ]; then
		fail_notice_exit "(${FUNCNAME[0]}) No recipe names specifed."
	fi
	for R in "${RECIPE_NAMES[@]}"
	do
		if [[ "$R" == "ALL" ]]; then
			RECIPE_NAMES=( $(ls "$OVERRIDE_DIR") )
			break
		fi
	done
}
usage_custom()
{
	debug_print -e -B -S "(${FUNCNAME[0]}) Started ${FUNCNAME[0]} function with args: $*"
	echo ""
	echo "	[OPTIONS] [RECIPE_NAME]"
	echo -n "	[--info|-i]: Show recipe info. Default: "
	[ $INFO -eq 0 ] && local_print -R "$(var_state $INFO)"
	[ $INFO -eq 1 ] && local_print -G "$(var_state $INFO)"
	echo "	[--name|-n] recipe: Specifiy a recipe name. Use this flage for each recipe. Specifying 'ALL' will select all recipes available in the OVERRIDE_DIR."
	echo "	--override-dir absolute-path-to-dir: Set the Override Directory. Default: $OVERRIDE_DIR"
	echo -n "	[--select|-s]: Interactively select a recipe from specified Override Directory. Default: "
	[ $SELECT -eq 0 ] && local_print -R "$(var_state $SELECT)"
	[ $SELECT -eq 1 ] && local_print -G "$(var_state $SELECT)"
	echo -n "	[--trust|-t]: Trust a recipe. Default: "
	[ $TRUST -eq 0 ] && local_print -R "$(var_state $TRUST)"
	[ $TRUST -eq 1 ] && local_print -G "$(var_state $TRUST)"
	echo -n "	[--verify|-v]: Verify trust info. Default: "
	[ $VERIFY -eq 0 ] && local_print -R "$(var_state $VERIFY)"
	[ $VERIFY -eq 1 ] && local_print -G "$(var_state $VERIFY)"
	echo ""
	echo "	[OPTIONS]"
	echo "	--get-trust-behavior: Retrieve the value of FAIL_RECIPES_WITHOUT_TRUST_INFO from com.github.autopkg."
	echo "	--set-trust-behavior-[true|false|none]: Set the value of FAIL_RECIPES_WITHOUT_TRUST_INFO for com.github.autopkg to true, false or none."
}
#### ####

#### Custom Functions ####
option_selector()
{
	# Only returns the index of the options. Need to manually get the item from the list.
	debug_print -e -B -S "(${FUNCNAME[0]}) Started ${FUNCNAME[0]} function with args: $*"
	[ $# -lt 2 ] && fail_notice_exit "(${FUNCNAME[0]}) Invalid use of option_selector. Missing args."
	INPUT_OPTS=( $@ )
	INDEX=0
	for o in "${INPUT_OPTS[@]}"
	do
		echo "[$INDEX] $o"
		((INDEX++))
	done
	index_selection=-1
	while [ $index_selection -lt 0 ] || [ $index_selection -gt $(((${#INPUT_OPTS[@]}-1))) ]
	do
		echo -n "Select an option: "
		read index_selection
		if [[ $index_selection =~ ^[0-9]+$ ]] && [ $index_selection -gt -1 ] && [ $index_selection -lt ${#INPUT_OPTS[@]} ]; then
			return "$index_selection"
		else
			local_print -e -Y -S "Invalid selection: $index_selection"
			index_selection=-1
		fi
	done
}
#### ####

#### Customizable Script Entry ####
if [ $# -lt 1 ] && [ $ARGS_REQUIRED -eq 1 ]; then
	local_print -e -R -S "($0) Missing arguments."
	usage
else
	parse_args "$@"
	main
fi
#### ####

exit 0
