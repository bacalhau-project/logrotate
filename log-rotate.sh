#!/bin/bash

# Step 0a: Create the logrotate configuration file
mkdir logs
LOGS_DIR="$PWD/logs"
LOGROTATE_CONF="/etc/logrotate.d/my_logs"

cat << EOF | sudo tee $LOGROTATE_CONF
$LOGS_DIR/*.log {
    hourly
    rotate 1
    missingok
    notifempty
    compress
    olddir /var/logs/raw_logs
}
EOF

# Step 0b: Create the log rotation output directory
sudo mkdir -p /var/logs/raw_logs

# Step 0c: Create the /etc/cron.hourly/ directory and set appropriate permissions
LOGROTATE_CRON_HOURLY="/etc/cron.hourly/logrotate"
sudo mkdir -p /etc/cron.hourly
sudo chown root:root /etc/cron.hourly
sudo chmod 755 /etc/cron.hourly

# Step 0d: Create a new logrotate script in the /etc/cron.hourly/ directory
sudo bash -c "echo '/usr/sbin/logrotate --hourly /etc/logrotate.conf' > $LOGROTATE_CRON_HOURLY"
sudo chmod +x $LOGROTATE_CRON_HOURLY

# Step 4: Create a systemd service
FAKE_LOG_GENERATOR_PY="$PWD/fake_log_generator.py"
SERVICE_FILE="fake-log-generator.service"

python3 $FAKE_LOG_GENERATOR_PY -d $LOGS_DIR