#!/bin/bash

wget -O - https://github.com/hashicorp/nomad-spark/releases/download/v2.3.2-nomad-0.8.6-20191029/spark-2.3.2-bin-nomad-0.8.6-20191029.tgz \
| sudo tar xz -C /usr/local
PATH=$PATH:/usr/local/spark-2.3.2-bin-nomad-0.8.6-20191029/bin