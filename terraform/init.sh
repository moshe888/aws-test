#!/bin/bash


cd /home/colman-project/backend/
nohup npm start > /var/log/node-server.log 2>&1 &
