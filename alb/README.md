# On your local machine — add key to agent

```
ssh-add ~/.ssh/myapp-key.pem
```

# Connect to bastion with agent forwarding

```
ssh -A ec2-user@<bastion_public_ip>
```

# From bastion — connect to app server (uses forwarded key)

```
ssh ec2-user@<app_server_private_ip>
```

The default username for Amazon Linux is `ec2-user`. For Ubuntu it's `ubuntu`.

# user_data didn't run or partially ran

```
SSH in and check /var/log/cloud-init-output.log
```

# Check that the volume is attached (shows as nvme1n1 on modern instances)

```
lsblk
```

# Format the volume with ext4 filesystem (do this ONCE — formatting destroys data)

```
sudo mkfs -t ext4 /dev/nvme1n1
```

# Create a mount point

```
sudo mkdir -p /data
```

# Mount the volume

```
sudo mount /dev/nvme1n1 /data
```

# Make it auto-mount on reboot — add to /etc/fstab

```
echo "/dev/nvme1n1 /data ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
```
