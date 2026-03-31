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
