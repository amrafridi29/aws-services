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
