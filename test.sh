#!/bin/bash

ping -c 2 localhost
read -t 2 aaaa
echo $?
