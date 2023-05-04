#!/bin/bash
mkdir logs

# Install logrotate if it's not already installed
apt-get update
apt-get install logrotate -y

# Create a new configuration file for logrotate
cat > /etc/logrotate.d/myapp <<EOL
/home/vedantpadwalinfi/logrotate/logs/fake_logs.log {
    hourly
    missingok
    rotate 24
    compress
    delaycompress
    notifempty
    create 0640 root adm
    postrotate
        invoke-rc.d rsyslog rotate > /dev/null
    endscript
}
EOL

# Create a new hourly cron job
cat > /etc/cron.hourly/logrotate-hourly <<EOL
#!/bin/sh
/usr/sbin/logrotate --state /var/lib/logrotate/logrotate.hourly.status /etc/logrotate.conf
EOL

# Make the script executable and restart the cron service
chmod +x /etc/cron.hourly/logrotate-hourly
service cron restart

# Create a systemd service
cat > fake-log-generator.service <<EOL
[Unit]
Description=Generate fake logs
After=network.target

[Service]
User=vedantpadwalinfi
WorkingDirectory=$(pwd)
ExecStart=/usr/bin/python3 fake_log_generator.py -d logs/
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Reload the systemd daemon, enable, and start the service
systemctl daemon-reload
systemctl enable fake_log_generator.service
systemctl start fake_log_generator.service

# Export the local directory allow list
export BACALHAU_LOCAL_DIRECTORY_ALLOW_LIST=/home/vedantpadwalinfi/logrotate/logs