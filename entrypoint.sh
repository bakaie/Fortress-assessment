#!/bin/bash
set -e


echo "Starting bftpd in passive mode on port 2121..."

/app/bftpd -D -c /etc/bftpd/bftpd.conf