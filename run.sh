#!/bin/bash

if [ -e /dev/sda1 ]
then
	if lsblk | grep /dev/sda1
	then
		echo flash is mounted already
	else
	        mount /dev/sda1 /mnt
	fi
#	mount /dev/sda1 /mnt
fi

		 if [ -e /sys/class/gpio/gpio18/value ]
                then
                        echo gpio is intilized

                else
                        echo "intilizing gpio 18 to in direction"
                        echo 18 > /sys/class/gpio/export
                        echo "in" > /sys/class/gpio/gpio18/direction
		fi

function check_gpio () {
	echo starting gpio checking thread
	while true
	do
		echo checking gpio
		if [ -e /sys/class/gpio/gpio18/value ]
		then
			val=$(cat /sys/class/gpio/gpio18/value)
			if [ $val -eq 0 ]
			then
				echo gpio is down then door closed
				if ! [ -e /tmp/door_is_closed ]
				then
					touch /tmp/door_is_closed
			                /opt/vc/bin/tvservice --off
					pkill omxplayer
				fi
				sleep .5
			else
				if [ -e  /tmp/door_is_closed ]
				then
					echo clearing door state
					rm  /tmp/door_is_closed
				        /opt/vc/bin/tvservice -p
				fi
				sleep 30
			fi
		fi
	done
}

check_gpio &
sleep 5
while true
do
  	if [ -e /tmp/door_is_closed ]
        then
		/opt/vc/bin/tvservice --off
                sleep 1
                continue
        fi

	/opt/vc/bin/tvservice -p
	for file in /mnt/*.mp4
	do
		if [ -e /tmp/door_is_closed ]
		then
			break
		fi
		echo playing $file
		omxplayer $file
	    	#whatever you need with "$file"
		sleep .1
	done
	sleep .1
done

exit 0
