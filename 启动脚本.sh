#!/bin/sh


# NOTE: This is an example that sets up SSH authorization. To use it, you'd need to replace "ssh-rsa AA... youremail@example.com" with your SSH public.
# You can replace this entire script with anything you'd like, there is no need to keep it


mkdir -p /root/.ssh
chmod 600 /root/.ssh
echo 公钥 > /root/.ssh/authorized_keys
chmod 700 /root/.ssh/authorized_keys