#!/bin/sh

# Helper script to manage
# guest VMs on remote host
# and open virt-viewer connection to machine(s)


# Variables
#
# The host machine, we assume we have SSH access with key-based authentication
export HOST=192.168.1.2
# QEMU connection
export QEMU="qemu:///system"
export QEMUREMOTE='qemu+ssh://'
export QEMUREMOTETRAIL='/system?socket=/var/run/libvirt/libvirt-sock'
export HOSTUSER="myuseraccount"

# Used to match short names (to be passed to script)
# to longer GUEST names that are on the host

export vlan200="testvm200"
export vlan200user="foo"
export vlan200pass="bar"

export vlan300="testvm300"
export vlan300user="bar"
export vlan300pass="foo"

# Functions


### Helpers

vm_alias() {
  eval VMNAME="$1"
  eval VM='$'$VMNAME
  if [[ ! "$VM" = "" ]] ; then
	export VM=$VM
  else
	export VM=$VMNAME
  fi	
}

vm_port() {
  eval VMPORTSTR="$1port"
  eval PORT='$'$VMPORTSTR
  if [[ ! "$PORT" = "" ]] ; then
	  export PORT=$PORT
  fi
}

vm_user() {
  eval VMUSER="$1user"
  eval USER='$'$VMUSER
  if [[ ! "$USER" = "" ]] ; then
	  export USER=$USER
  fi
}

vm_pass() {
  eval VMPASS="$1pass"
  eval PASS='$'$VMPASS
  if [[ ! "$PASS" = "" ]] ; then
	  export PASS=$PASS
  fi
}

### Virsh related functions

usage() { 
  echo "Usage: `basename $0` <command> <VM-name or alias (see script source)>"
  echo "Available commands:\n"
  echo "connect <VM-name> [host] [SSH user]
 -- Open virt-viewer session to remote guest,
    will attempt to start VM if not running."
  echo "start <VM-name> [host]
-- Attempt to start the VM."
  echo "status [VM-name] [host]
-- Print VM status, if no VM defined, will list everything."
  echo "shutdown <VM-name> [host]
-- Attempt to shutdown the VM."
  echo "reboot <VM-name> [host]
 -- Attempt to reboot the VM."
  echo "text <VM-name> <text> <target file> [Host-server [VM-user [VM-pass]]]
-- Paste text to the target server, remember to escape your string"
 echo "file <VM-name> <file> <target file> [Host-server [VM-user [VM-pass]]]
-- Paste text from a local file to target server."
  export EXIT_CODE=-1
}

execute() {
  case $1 in
	status)
		echo "Getting status..."
		;;
	start)
		echo "Attempting to start..."
		;;
	shutdown)
		echo "Attempting to shutdown..."
		;;
	reboot)
		echo "Attempting to reboot..."
		;;
	connect)
		echo "Attempting to connect..."
		;;
  esac

  ssh $2 "virsh -c $QEMU ${@:3}" 
}

status() {
  if [[ $# -eq 1 ]] ; then
	execute 0 $HOST list --all
  elif [[ $# -eq 2 ]] ; then
	vm_alias $1
	if [[ $(execute "status" $HOST list | grep -c $VM) -eq 1 ]] ; then
		if [[ $2 -eq 1 ]] ; then
			echo "$VM is running"
		fi
		export EXIT_CODE=1
		return 0
 	else
		if [[ $2 -eq 1 ]] ; then
			echo "$VM is powered off"
		fi
		export EXIT_CODE=1
		return 1
	fi
  elif [[ $# -eq 3 ]] ; then
	vm_alias $1
	if [[ $(execute "status" $2 list | grep -c $VM) -eq 1 ]] ; then
		if [[ $3 -eq 1 ]] ; then
			echo "$VM is running"
		fi
		export EXIT_CODE=0
		return 0
 	else
		if [[ $3 -eq 1 ]] ; then
			echo "$VM is powered off"
		fi
		export EXIT_CODE=1
		return 1
	fi
  else
	  usage
  fi
}

power() {
    if [[ $# -eq 2 || $# -eq 3 ]] ; then
	vars=(${@:2})
	status ${vars[@]} 1
        MACHINE=$?	
	if [[ ( $MACHINE -eq 1 && $1 == "shutdown" ) || ( $MACHINE -eq 0 && $1 == "start" )  ]] ; then
		export EXIT_CODE=0
		return 0
	elif [[ $MACHINE -eq 0 && $1 == "reboot" ]] ; then
		COMMAND="reboot"
	elif [[ $MACHINE -eq 1 && $1 == "reboot" ]] ; then
		COMMAND="start"
	elif [[ $1 == "start" ]] ; then
		COMMAND="start"
	else
		COMMAND="shutdown"
	fi
	
	vm_alias ${vars[0]}
	
	if [[ ${#vars[@]} -eq 1 ]] ; then
		execute "$COMMAND" $HOST $COMMAND $VM
	elif [[ ${#vars[@]} -eq 2 ]] ; then
		execute "$COMMAND" ${vars[1]} $COMMAND $VM
	fi
	
	if [[ $? -eq 0 ]] ; then
		export EXIT_CODE=0
		return 0
	else
		echo "!!! Something went wrong"
		export EXIT_CODE=3
		return 3
	fi
  else
	  usage
   fi
}

connect() {
  if [[ $# -eq 1 || $# -eq 2 || $# -eq 3 ]] ; then
	vars=($@)
	
	if [[ ! ${#vars[@]} -eq 3 ]] ; then 
		CONNECT_USER=$HOSTUSER
       	else
		CONNECT_USER=${vars[2]}
	fi
	vm_alias ${vars[0]}

	if [[ ! ${#vars[@]} -eq 1 ]] ; then
		STATUSARGS="${vars[0]} ${vars[1]}"
		HOST="${vars[1]}"
	else
		STATUSARGS="${vars[0]}"
	fi

	CONNECT_CMD="virt-viewer -c $QEMUREMOTE$CONNECT_USER@$HOST$QEMUREMOTETRAIL $VM 2>/dev/null &"
	
	status $STATUSARGS 0
	
	if [[ $? -eq 0 ]] ; then
		eval $CONNECT_CMD
	else
		power start $STATUSARGS
		if [[ $? -eq 0 ]] ; then
			sleep 2
			eval $CONNECT_CMD
		else
			export EXIT_CODE=5
			return 5
		fi
       fi
  else
	usage
  fi
}

### Functions to pass text to VMs
#   since Clipboard sharing is not
#   working properly with Mac+remote

# Doing via exporting to .exp file as
# running /usr/bin/expect from inside .sh
# is PITA
paste() {
  if [[ $# -eq 8 ]] ; then  # should improve and add "HOSTUSER" to be passed from 
    expfile="/tmp/expect-script$$.exp"

    cat <<EOF > $expfile 
#!/usr/bin/expect
set timeout 10
spawn virsh -c $7$HOSTUSER@$1$QEMUREMOTETRAIL console --force $2
expect "Escape character is"
send "\n"
expect "login: " {
  send "$3\n"
  expect "Salasana: "
  send "$4\n"
} "~]# " {
send "\n"
}
send "echo \"$6\" > /home/$3/$5\n"
send "exit\n"
send -- "^]"
send "exit\n"
EOF


    expect $expfile >/dev/null
    rm $expfile # comment out this line to debug expect part
  else
    echo "do failure here"
  fi
}

pastefile() {
   if [[ $# -eq 3 || $# -eq 4 || $# -eq 5 || $# -eq 6 ]] ; then
    COUNT=$#
    ARG1=$1
    ARG2=$2
    ARG3=$3
    ARG4=$4
    ARG5=$5
    ARG6=$6
	  
    vm_alias $ARG1
    if [[ $COUNT -eq 3 ]] ; then 
      PASTE_HOST=$HOST
      vm_user $ARG1
      vm_pass $ARG1
    elif [[ $COUNT -eq 4 ]] ; then
      PASTE_HOST=$ARG4
      vm_user $ARG1
      vm_pass $ARG1
    elif [[ $COUNT -eq 5 ]] ; then
      PASTE_HOST=$ARG4
      USER=$ARG5
      vm_pass $ARG1
    else
      PASTE_HOST=$ARG4
      USER=$ARG5
      PASS=$ARG6
    fi
    PASTE_TEXT=`cat $ARG2`
    TARGET_FILE=$ARG3

    paste $PASTE_HOST $VM $USER $PASS $TARGET_FILE "$PASTE_TEXT" $QEMUREMOTE $QEMUREMOTETRAIL

  else
    usage
  fi
}

pastetext() {
  if [[ $# -eq 3 || $# -eq 4 || $# -eq 5 || $# -eq 6 ]] ; then
    COUNT=$#
    ARG1=$1
    ARG2=$2
    ARG3=$3
    ARG4=$4
    ARG5=$5
    ARG6=$6
	  
    vm_alias $ARG1
    if [[ $COUNT -eq 3 ]] ; then 
      PASTE_HOST=$HOST
      vm_user $ARG1
      vm_pass $ARG1
    elif [[ $COUNT -eq 4 ]] ; then
      PASTE_HOST=$ARG4
      vm_user $ARG1
      vm_pass $ARG1
    elif [[ $COUNT -eq 5 ]] ; then
      PASTE_HOST=$ARG4
      USER=$ARG5
      vm_pass $ARG1
    else
      PASTE_HOST=$ARG4
      USER=$ARG5
      PASS=$ARG6
    fi
    PASTE_TEXT="$ARG2"
    TARGET_FILE="$ARG3"

   paste $PASTE_HOST $VM $USER $PASS $TARGET_FILE "$PASTE_TEXT" $QEMUREMOTE $QEMUREMOTETRAIL

  else
    usage
  fi
}

### Main

case $1 in
	connect)
		connect ${@:2}
 
		;;
	start)
		 power ${@:1}
		 
		;;
	status)
		status ${@:2} 1
		;;
	shutdown)
		power ${@:1}

		;;
	reboot)
		power ${@:1}
		;;
	file)
		pastefile ${@:2}
		;;
	text)
		pastetext "${@:2}"
		;;
	*)
		usage
		;;
esac

exit $EXIT_CODE
