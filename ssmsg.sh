#!/bin/sh

#               SSMSG v0.1
#    Single file SQL MySensors* Gateway
#    * see www.mysensors.org for more information
#
#    Copyright (C) 2014 Daniel Wiegert
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>
#
#
# Option                Meaning
#  -f                   Run in foreground
#  -x                   Kill script

# Config
SERIALPORT=/dev/ttyUSB0
mysql_user=sensor
mysql_password=sensor
mysql_host=127.0.0.1
mysql_database=sensors
# /Config

SCRIPTNAME=`basename $0`
PIDFILE=/var/run/${SCRIPTNAME}.pid

# Kill script -x
if [ "x$1" == "x-x"  ] ; then
        killall ${SCRIPTNAME}
        exit 0
fi

# Create or check pid-file if process is already running.
if [ -f ${PIDFILE} ] ; then
   OLDPID=`cat ${PIDFILE}`
   RESULT=`ps -ef | grep ${OLDPID} | grep ${SCRIPTNAME}`
   if [ -n "${RESULT}" ] ; then
     echo "Script already running! Exiting. Run with -x to kill and restart."
     exit 255
   fi
fi
echo $$ > ${PIDFILE}

# Detach and become a daemon
if [ "x$1" != "x-f"  ] ; then
        $0 -f 1> /dev/null 2> /dev/null &
        exit 0
fi

# Setup serial port
stty -F $SERIALPORT cs8 115200 -ignbrk -ignpar -raw -echo -cstopb -icrnl -onlcr

# Start read thread
while read line; do
        echo $line
        # Split incomming message into array, ignoring 0 in beginning
        IFS=';' read -a array <<< "$line"
        array[4]=$(printf '%q' "${array[4]}")
        if [ "${array[3]}" != 9 ]; then
                # Get next nodeid from DB and send response
                if [ "${array[2]}" == 3 ] && [ "${array[3]}" == 3 ] ; then
                        id=`mysql -u ${mysql_user} -p${mysql_password} -h ${mysql_host} ${mysql_database} -ss -e \
                          "SELECT u.nodeid + 1 AS id FROM node u LEFT JOIN node u1 ON u1.nodeid = u.nodeid + 1 \
                          WHERE u1.nodeid IS NULL ORDER BY u.nodeid LIMIT 0, 1;"`
                        # If table is empty, set id to 1
                        if [ "$id" -le 1 -a "$id" -ge 255 ]; then
                                id=1
                        fi
                        echo "Responding nodeid $id back to node. (with no ack)"
                        echo -e -n "255;255;3;0;4;$id\n" > $SERIALPORT
                fi
                # Respond to config requests
                if [ "${array[2]}" == 3 ] && [ "${array[3]}" == 6 ] ; then
                        val=`mysql -u ${mysql_user} -p${mysql_password} -h ${mysql_host} ${mysql_database} -ss -e \
                          "SELECT value FROM config WHERE configid=${array[4]} LIMIT 1;"`
                        echo -e -n "${array[0]};255;3;0;6;$val\n" > $SERIALPORT
                        echo "Responding configid ${array[4]} ($val)...."
                fi

                # Insert node in table along with type and version
                if [ "${array[2]}" == 0 ] && [ "${array[3]}" == 17 ] || [ "${array[3]}" == 18 ] ; then
                        echo "Detected node ${array[0]} (${array[4]})"
                        echo "INSERT INTO node (nodeid, type, version, lastseen) VALUES (${array[0]}, ${array[3]}, '${array[4]}', NOW()) \
                          ON DUPLICATE KEY UPDATE nodeid=${array[0]}, type=${array[3]}, version='${array[4]}', lastseen=NOW();" | \
                            mysql -u ${mysql_user} -p${mysql_password} -h ${mysql_host} ${mysql_database}
                fi
                # Update I_SKETCH_NAME
                if [ "${array[2]}" == 3 ] && [ "${array[3]}" == 11 ] ; then
                        echo "UPDATE node SET I_SKETCH_NAME='${array[4]}' WHERE nodeid=${array[0]}" | \
                          mysql -u ${mysql_user} -p${mysql_password} -h ${mysql_host} ${mysql_database}
                fi
                # Update I_SKETCH_VERSION
                if [ "${array[2]}" == 3 ] && [ "${array[3]}" == 12 ] ; then
                        echo "UPDATE node SET I_SKETCH_VERSION='${array[4]}' WHERE nodeid=${array[0]}" | \
                          mysql -u ${mysql_user} -p${mysql_password} -h ${mysql_host} ${mysql_database}
                fi
                # Insert into sensorlist
                if [ "${array[2]}" == 0 ] && [ "${array[1]}" != 255 ] ; then
                        echo "INSERT INTO sensorlist SET nodeid='${array[0]}', childid='${array[1]}', type='${array[3]}' \
                          ON DUPLICATE KEY UPDATE nodeid='${array[0]}', childid='${array[1]}', type='${array[3]}';" | \
                            mysql -u ${mysql_user} -p${mysql_password} -h ${mysql_host} ${mysql_database}
                fi
                # Insert data into sensordata
                if [ "${array[2]}" == 1 ] ; then
                        echo "INSERT INTO sensordata SET nodeid='${array[0]}', childid='${array[1]}', value='${array[4]}', datetime=NOW();" | \
                          mysql -u ${mysql_user} -p${mysql_password} -h ${mysql_host} ${mysql_database}
                fi

        fi

done < $SERIALPORT &

#Start send thread
while true; do
        sleep 5
        mysql -u ${mysql_user} -p${mysql_password} -h ${mysql_host} ${mysql_database} -ss -e \
          "SELECT nodeid,childid,messagetype,'0',subtype,payload FROM sendrequest WHERE sent IS NULL ORDER BY id; \
            UPDATE sendrequest set sent=NOW() WHERE sent IS NULL ORDER BY id limit 1;" \
              | sed -e 's/\t/;/g' | while read -r line
        do
                echo -e $line > $SERIALPORT
                echo "Sending : $line"
                sleep 5
        done
done &

wait
echo "exit"
