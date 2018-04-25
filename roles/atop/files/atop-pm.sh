#!/bin/bash
# This file was installed by an Ansible role.
# Any manual changes will be destroyed when the role is re-applied.
# 
# This fixes atop logfile rotation when suspending a Fedora laptop.
# https://bugzilla.redhat.com/show_bug.cgi?id=1571866

case "$1" in
	pre)	exit 0
		;;
	post)	/usr/bin/systemctl try-restart atop
		exit 0
		;;
 	*)	exit 1
		;;
esac
