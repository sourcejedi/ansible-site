#!/bin/sh
set -e

gpg --with-fingerprint "$1" |
	sed -ne 's/.*Key fingerprint = \(.*\)/\1/ p' |
	sort

# Fingerprints are sorted, for easy comparison
