#!/bin/bash
#######################################################
#
#        File: mycommands.sh.clean
#
# copy to mycommands.sh and add all your commands and functions here ...
#
#       Usage: will be executed when a bot command is received 
#
#     License: WTFPLv2 http://www.wtfpl.net/txt/copying/
#      Author: KayM (gnadelwartz), kay@rrr.de
#
#### $$VERSION$$ v1.51-0-g6e66a28
#######################################################
# shellcheck disable=SC1117

####################
# Config has moved to bashbot.conf
# shellcheck source=./commands.sh
[ -r "${BASHBOT_ETC:-.}/mycommands.conf" ] && source "${BASHBOT_ETC:-.}/mycommands.conf"  "$1"


##################
# lets's go
if [ "$1" = "startbot" ];then
    ###################
    # this section is processed on startup

    # run once after startup when the first message is received
    my_startup(){
	notify-send "Telegram bot started"
    }
    touch .mystartup
else
    # call my_startup on first message after startup
    # things to do only once
    [ -f .mystartup ] && rm -f .mystartup && _exec_if_function my_startup

    #############################
    # your own bashbot commands
    # NOTE: command can have @botname attached, you must add * to case tests...
    mycommands() {

	##############
	# a service Message was received
	# add your own stuff here
	if [ -n "${SERVICE}" ]; then
		# example: delete every service message
		if [ "${SILENCER}" = "yes" ]; then
			delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"
		fi
	fi

	# remove keyboard if you use keyboards
	[ -n "${REMOVEKEYBOARD}" ] && remove_keyboard "${CHAT[ID]}" &
	[[ -n "${REMOVEKEYBOARD_PRIVATE}" &&  "${CHAT[ID]}" == "${USER[ID]}" ]] && remove_keyboard "${CHAT[ID]}" &

	# uncommet to fix first letter upper case because of smartphone auto correction
	#[[ "${MESSAGE}" =~  ^/[[:upper:]] ]] && MESSAGE="${MESSAGE:0:1}$(tr '[:upper:]' '[:lower:]' <<<"${MESSAGE:1:1}")${MESSAGE:2}"
	case "${MESSAGE}" in
		##################
		# example command, replace them by your own
		'.echo'*) # example echo command
			send_normal_message "${CHAT[ID]}" "${MESSAGE#.echo}"
			;;

		##########
		# command overwrite examples
		# return 0 -> run default command afterwards
		# return 1 -> skip possible default commands
		# '.info'*) # output date in front of regular info
		# 	send_normal_message "${CHAT[ID]}" "$(date)"
		# 	return 0
		# 	;;
		'.kickme'*) # this will replace the /kickme command
			send_markdownv2_mesage "${CHAT[ID]}" "This bot will *not* kick you!"
			return 1
			;;
		'/start'*)
			send_normal_message "noU"
			return 1
			;;
		# '/help'*)
		# 	send_normal_message "This bot can't help with your life, seriously."
		# 	return 1
		# 	;;
		'.calc'*)
			tocalc="${MESSAGE#.calc}"
			calced=$(echo "${tocalc}" | bc -l)
			calced2=$(round "${calced}" 3)
			# calced2=$(round)
			send_normal_message "${CHAT[ID]}" "${calced2}"
			unset tocalc calced
			return 1
			;;
		# '.set_decimal_places'*)
		# 	pre_received="${MESSAGE#.set_decimal_places}"
		# 	received=$(echo "${pre_received}" | sed 's/[^0-9]*//g' | tr -d ' ' | tr -d '\n')
		# 	if [ -n "${received}" ]; then
		# 		decimal_places="${received}"
		# 		send_normal_message "${CHAT[ID]}" "Decimal point set to ${decimal_places}"
		# 	else
		# 		send_normal_message "${CHAT[ID]}" "Not enough arguement(s)"
		# 	fi
		# 	;;
		# '.del'*)
		# 	if [ -z "${REPLYTO[ID]}" ]; then
		# 		send_normal_message "${CHAT[ID]}" "Please reply to a message first!"
		# 	else
		# 		delete_message "${CHAT[ID]}" "${REPLYTO[ID]}"
		# 		delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"
		# 		send_normal_message "${CHAT[ID]}" "Message with ID: ${REPLYTO[ID]} deleted!"
		# 	fi
		# 	;;
		# '.upload'*)
		# 	# upload file in ~/Downloads/empty/
		# 	# Check if the folder is empty
		# 	local HOME=/home/hakimi
		# 	if [ -z "$(ls -A $HOME/Downloads/empty/)" ]; then
		# 		send_normal_message "${CHAT[ID]}" "No files to upload"
		# 	# check if there's more than one file in the folder
		# 	elif [ "$(ls -A $HOME/Downloads/empty/ | wc -l)" -gt 1 ]; then
		# 		send_normal_message "${CHAT[ID]}" "More than one file in the folder, please delete all but one"
		# 	else
		# 		# upload file
		# 		send_file "${CHAT[ID]}" "$HOME/Downloads/empty/$(ls $HOME/Downloads/empty/)"
		# 		# delete file
		# 		rm -f ~/Downloads/empty/*
		# 	fi
		'.send_ch'*)
			channel_id=-1001664444944
			send_message "${channel_id}" "${MESSAGE#.send_ch}"
			send_normal_message "${CHAT[ID]}" "Message sent to channel"
			;;
		# '.purge'*)
		# 	# get replied message id and purge in between
		# 	replied_message_id=${REPLYTO[ID]}
		# 	message_id=${MESSAGE[ID]}
		# 	if [ -z "$replied_message_id" ]; then
		# 		send_normal_message "${CHAT[ID]}" "Please reply to a message first!"
		# 	else
		# 		for ((message=replied_message_id; message<=message_id; message++)); do
		# 			delete_message "${CHAT[ID]}" "${message}"
		# 		done
		# 	fi
		# 	send_normal_message "Slow af purge complete."
		# 	;;
		'.spam'*)
			# Same as echo but repeats the message
			repeat=15
			msg="${MESSAGE#.spam}"
			send_normal_message "${CHAT[ID]}" "${msg}"
			for ((i=1; i<=repeat; i++)); do
				send_normal_message "${CHAT[ID]}" "${msg}"
			done
			unset repeat msg
			;;
		'.ilmu'*)
			# laki_og_group_id=-1001296316951
			fwd_msg_group_id=-1001155763792
			ilmu_data_id=15620
			forward_message "${CHAT[ID]}" "${fwd_msg_group_id}" "${ilmu_data_id}"
			;;
		'.ping'*)
			send_markdown_message "*pong!*"
			;;
		'.magisk'*)
			unset latest
			latest=$(
				curl -s https://api.github.com/repos/topjohnwu/Magisk/releases/latest \
					| grep "Magisk-v**.*.apk" \
					| cut -d : -f 2,3 \
					| tr -d \" \
					| cut -d, -f2 \
					| tr -d '\n' \
					| tr -d ' '
			)
			send_markdown_message "${CHAT[ID]}" "[Latest stable](${latest})\n[Latest canary](https://raw.githubusercontent.com/topjohnwu/magisk-files/canary/app-debug.apk)"
			unset latest
			;;
	esac
     }

     mycallbacks() {
	#######################
	# callbacks from buttons attached to messages will be  processed here
	case "${iBUTTON[USER_ID]}+${iBUTTON[CHAT_ID]}" in
	    *)	# all other callbacks are processed here
		local callback_answer
		: # your processing here ...
		:
		# Telegram needs an ack each callback query, default empty
		answer_callback_query "${iBUTTON[ID]}" "${callback_answer}"
		;;
	esac
     }
     myinlines() {
	#######################
	# this fuinction is called only if you has set INLINE=1 !!
	# shellcheck disable=SC2128
	iQUERY="${iQUERY,,}"


	case "${iQUERY}" in
		##################
		# example inline command, replace it by your own
		"image "*) # search images with yahoo
			local search="${iQUERY#* }"
			answer_inline_multi "${iQUERY[ID]}" "$(my_image_search "${search}")"
			;;
	esac
     }

    #####################
    # place your processing functions here

    # example inline processing function, not really useful
    # $1 search parameter
#     round() {
# 	# round function made by github copilot
# 	# usage: round <number> <decimal places>
# 	# example: round 1.2345 2
# 	# returns: 1.23
# 	echo $(printf %.$2f $(echo "scale=$2;(((10^$2)*$1)+0.5)/(10^$2)" | bc));
# 	}
    my_image_search(){
	local image result sep="" count="1"
	result="$(wget --user-agent 'Mozilla/5.0' -qO - "https://images.search.yahoo.com/search/images?p=$1" |  sed 's/</\n</g' | grep "<img src=")"
	while read -r image; do
		[ "${count}" -gt "20" ] && break
		image="${image#* src=\'}"; image="${image%%&pid=*}"
		[[ "${image}" = *"src="* ]] && continue
		printf "%s\n" "${sep}"; inline_query_compose "${RANDOM}" "photo" "${image}"; sep=","
		count=$(( count + 1 ))
	done <<<"${result}"
    }

    ###########################
    # example error processing
    # called when delete Message failed
    # func="$1" err="$2" chat="$3" user="$4" emsg="$5" remaining args
    bashbotError_delete_message() {
	log_debug "custom errorProcessing delete_message: ERR=$2 CHAT=$3 MSGID=$6 ERTXT=$5"
    }

    # called when error 403 is returned (and no func processing)
    # func="$1" err="$2" chat="$3" user="$4" emsg="$5" remaining args
    bashbotError_403() {
	log_debug "custom errorProcessing error 403: FUNC=$1 CHAT=$3 USER=${4:-no-user} MSGID=$6 ERTXT=$5"
    }
fi
