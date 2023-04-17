#!/bin/bash
for J in $(cat /etc/nginx/encoder_list.txt );
        do
                echo "## CH LIST ENCODER $J" >  /etc/nginx/$J.conf
                for i in $(curl -s -u user1:pass1 http://$J/flussonic/api/v3/streams | jq '.streams[].name' | sed "s/\"//g" | cut -d '/' -f2);
                        do
                        echo "Encoder $J - Canal $i"
                        echo "upstream $i {server $J:80;}" >> /etc/nginx/$J.conf
                done;
        done;
