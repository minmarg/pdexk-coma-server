#!/bin/bash

java -Xms2048M  -Djetty.port=8085 -jar start.jar etc/jetty.xml
