#!/bin/bash

SERVER=https://api.no.de
SCRIPT="$0"
if [ ${SCRIPT:0:1} == "/" ]; then
	SCRIPT="$(basename -- "$SCRIPT")"
fi

main () {
	cmd=${1-help}
	shift
	case $cmd in
		-h | --h | -? | --? | --help ) cmd=help ;;
	esac
	$cmd "$@" && exit 0 || fail "failed"
}

help () {
cat <<HELP

Joyent no.de API Client Script

Usage:

$SCRIPT login - Provide/create Joyent credentials. (Stored in ~/.joyentrc.)
$SCRIPT userinfo - Change or view your userinfo (Requires password)
$SCRIPT changepass - Change your password.
$SCRIPT sendkeys - Send your ~/.ssh/*.pub keys to Joyent

$SCRIPT coupon request - Request a coupon code.
$SCRIPT coupon list - List out valid coupon codes in your account
$SCRIPT coupon use <code> - Load a coupon code to create a machine

$SCRIPT create [subdomain] - Create a no.de machine. Optionally supply a subdomain.
$SCRIPT machine [id] - Show data about a particular machine (or all machines)
$SCRIPT status [id] - Show status of a machine (or all machines)

Userinfo is stored in $HOME/.npmrc, owned by $USER, with mode 0600.

HELP
}

sendkeys () {
	login
	for key in $HOME/.ssh/*.pub; do
		curl -k -u $U:$P $SERVER/sshkeys -F "name=$U" -F "key=@$key"
	done
	curl -k -u $U:$P $SERVER/sshkeys
}

coupon () {
	cmd="$1"
	shift
	case $cmd in
		approve | request | list | use | delete) coupon_$cmd "$@" ;;
		*) fail "Usage: coupon [ list | request | use <code> ]" ;;
	esac
}
coupon_delete () {
	login
	if [ "$1" == "" ]; then
		fail "Supply an ID to delete"
	fi
	curl -ik -u $U:$P $SERVER/coupons/$1 -X DELETE
}
coupon_approve () {
	login
	if [ "$1" == "" ]; then
		fail "Supply an ID to approve"
	fi
	curl -ik -u $U:$P $SERVER/coupons/$1 -X PUT -F "approved=true"
}
coupon_list () {
	login
	curl -k -u $U:$P $SERVER/coupons
}
coupon_request () {
	login
	curl -k -u $U:$P $SERVER/♥ -X POST
}
coupon_use () {
	if [ "$1" == "" ]; then
		fail "Usage: $SCRIPT coupon <code>"
	fi
	echo "COUPON=$1" >> ~/.joyentrc
}


# curl -k -u jill:secret https://72.2.126.21/smartmachines/node
create () {
	login
	if [ "$COUPON" == "" ]; then
		echo "You are requesting without a coupon. If you're not an admin, this will fail." >&2
	fi
	if [ "$1" != "" ]; then
		curl -X POST -k -u $U:$P $SERVER/smartmachines/node -F subdomain="$1" -F coupon="$COUPON"
	else
		curl -X POST -k -u $U:$P $SERVER/smartmachines/node -F coupon="$COUPON"
	fi
}
machine () {
	login
	if [ "$1" == "" ]; then
		machines && return 0
	fi
	curl -k -u $U:$P $SERVER/smartmachines/node/$1
}
machines () {
	login
	curl -ik -u $U:$P $SERVER/smartmachines/node
}
status () {
	login
	if [ "$1" == "" ]; then
		machines 2>/dev/null | grep uri | egrep -o '[0-9]+' | while read id ; do
			[ "$id" != "" ] && status $id
		done
	else
		echo -n "$1: "
		curl -k -u $U:$P $SERVER/smartmachines/node/$1/status
	fi
}
destroy () {
	login
	if [ "$1" == "" ]; then
		fail "usage: destroy <id>"
	fi
	curl -k -X DELETE -u $U:$P $SERVER/smartmachines/node/$1
}

login () {
	auth
	if [ -z "$U" ]; then
		userinfo_
	fi
}

auth () {
	if [ -f $HOME/.joyentrc ]; then
		. $HOME/.joyentrc
		export U P COUPON COMP PHONE EMAIL FIRST LAST
	else
		touch $HOME/.joyentrc
		userinfo_
	fi
}
logout () {
	echo -n "" > $HOME/.joyentrc # empty hardlinks
	rm $HOME/.joyentrc
}
userinfo () {
	auth
	if [ -f $HOME/.joyentrc ]; then
		userinfo_
	fi
}	
userinfo_ () {
	changed=0
	read -p "Username? ($U) " user
	if [ "$U" == "" ] || [ "$user" != "" ]; then
		[ "$U" != "$user" ] && changed=1
		U=$user
	fi
	read -sp "Password? " pass
	echo
	if [ -z "$P" ]; then
		read -sp "Confirm Password? " conf		
		echo
		if [ "$conf" != "$pass" ]; then
			fail "password conf fail"
		fi
		[ "$P" != "$pass" ] && changed=1
		P="$pass"
	elif [ "$P" != "$pass" ]; then
		fail "invalid password"
	fi
	read -p "Company? ($COMP) " comp
	if [ "$COMP" == "" ] || [ "$comp" != "" ]; then
		[ "$COMP" != "$comp" ] && changed=1
		COMP=$comp
	fi
	read -p "Email? ($EMAIL) " email
	if [ "$EMAIL" == "" ] || [ "$email" != "" ]; then
		[ "$EMAIL" != "$email" ] && changed=1
		EMAIL=$email
	fi
	read -p "Phone? ($PHONE) " phone
	if [ "$PHONE" == "" ] || [ "$phone" != "" ]; then
		[ "$PHONE" != "$phone" ] && changed=1
		PHONE=$phone
	fi
	read -p "First name? ($FIRST) " first
	if [ "$FIRST" == "" ] || [ "$first" != "" ]; then
		[ "$FIRST" != "$first" ] && changed=1
		FIRST=$first
	fi
	read -p "Last name? ($LAST) " last
	if [ "$LAST" == "" ] || [ "$last" != "" ]; then
		[ "$LAST" != "$last" ] && changed=1
		LAST=$last
	fi
	cat >$HOME/.joyentrc <<CONF
U="$U"
P="$P"
COMP="$COMP"
PHONE="$PHONE"
EMAIL="$EMAIL"
FIRST="$FIRST"
LAST="$LAST"
SERVER="$SERVER"
COUPON="$COUPON"
CONF
	chmod 0600 $HOME/.joyentrc
	auth
	if [ $changed -eq 1 ]; then
		echo "Already have a Joyent account?"
		select already in yes no; do
			case $already in
				no) createaccount ;;
				yes) saveuserinfo ;;
			esac
			return 0
		done
	fi
}
# $ curl -k https://72.2.126.21/account \
#   -F "email=jill@joyent.com" \
#   -F "username=jill" \
#   -F "password=secret" \
#   -F "password_confirmation=secret"
createaccount () {
	echo $SERVER/account
	curl -k $SERVER/account \
		-F "email=$EMAIL"     \
		-F "username=$U"      \
		-F "password=$P"      \
		-F "phone=$PHONE"     \
		-F "company=$COMP"    \
		-F "first_name=$FIRST"    \
		-F "last_name=$LAST"      \
		-F "password_confirmation=$P"
}
saveuserinfo () {
	echo $SERVER/account
	curl -k $SERVER/account \
		-X PUT                \
		-u "$U:$P"            \
		-F "email=$EMAIL"     \
		-F "username=$U"      \
		-F "password=$P"      \
		-F "phone=$PHONE"     \
		-F "company=$COMP"    \
		-F "first_name=$FIRST"    \
		-F "last_name=$LAST"      \
		-F "password_confirmation=$P"
}	
changepass () {
	auth
	read -p "Username? ($U) " user
	if [ "$U" == "" ] || [ "$user" != "" ]; then
		[ "$U" != "$user" ] && changed=1
		U=$user
	fi
	read -sp "Current password? " P
	echo
	read -sp "New password? " new
	echo
	read -sp "Confirm Password? " conf		
	echo
	if [ "$conf" != "$new" ]; then
		fail "password conf fail"
	fi
	echo $SERVER/account
	curl -k $SERVER/account \
		-X PUT                \
		-u "$U:$P"            \
		-F "email=$EMAIL"     \
		-F "username=$U"      \
		-F "password=$new"    \
		-F "phone=$PHONE"     \
		-F "company=$COMP"    \
		-F "first_name=$FIRST"    \
		-F "last_name=$LAST"      \
		-F "password_confirmation=$conf"
	cat >$HOME/.joyentrc <<CONF
U="$U"
P="$new"
COMP="$COMP"
PHONE="$PHONE"
EMAIL="$EMAIL"
FIRST="$FIRST"
LAST="$LAST"
SERVER="$SERVER"
COUPON="$COUPON"
CONF
	chmod 0600 $HOME/.joyentrc
	auth
}

fail () {
	if ! [ -z "$1" ]; then
		echo $1 >&2
	fi
	exit 1
}

main "$@"
