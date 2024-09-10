#!/bin/bash
 
java -Xms2048M  -Djetty.port=8090 -jar start.jar etc/jetty.xml
