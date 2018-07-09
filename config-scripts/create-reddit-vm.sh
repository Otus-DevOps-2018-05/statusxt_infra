#!/bin/bash
gcloud compute instances create reddit-vm\
 --boot-disk-size=10GB \
 --image-family reddit-full \
 --machine-type=f1-micro \
 --tags puma-server \
 --restart-on-failure
