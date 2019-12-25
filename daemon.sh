#!/bin/bash

sudo -u postgres pg_ctlcluster $PG_VER main start
ccm start --root

echo infinite sleep
sleep infinity
