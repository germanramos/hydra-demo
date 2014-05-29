#!/bin/sh
exec ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/innotechdev/.ssh/id_rsa "$@"