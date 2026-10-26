```bash
#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/roboshop"
LOGS_FILE="${LOGS_FOLDER}/$(basename "$0" .sh).log"
SCRIPTS_DIR=$(dirname "$(realpath "$0")")
DOMAIN_NAME="daws92s.store"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# Check root access
check_root() {
    if [ "$USER_ID" -ne 0 ]; then
        echo "Please run this script with sudo access."
        exit 1
    fi
}

# Timestamp function
timestamp() {
    date "+%F %T"
}

# Create log directory
mkdir -p "$LOGS_FOLDER"

# Start logging
echo -e "$(timestamp) [INFO] ==== Script started Execution =====" | tee -a "$LOGS_FILE"

# Validate command execution
validate() {
    if [ "$1" -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] ${2}..${R}FAILED${N}" | tee -a "$LOGS_FILE"
        exit 1
    else
        echo -e "$(timestamp) [INFO] ${2}..${G}SUCCESS${N}" | tee -a "$LOGS_FILE"
    fi
}

# Install Node.js 24
nodejs_setup() {
    echo "Disabling existing Node.js module..." | tee -a "$LOGS_FILE"
    dnf module disable nodejs -y &>> "$LOGS_FILE"
    validate $? "Disabling existing Node.js module"

    echo "Enabling Node.js 24 module..." | tee -a "$LOGS_FILE"
    dnf module enable nodejs:24 -y &>> "$LOGS_FILE"
    validate $? "Enabling Node.js 24 module"

    echo "Installing Node.js..." | tee -a "$LOGS_FILE"
    dnf install nodejs -y &>> "$LOGS_FILE"
    validate $? "Installing Node.js 24"

    # Install application dependencies
    cd "$SCRIPTS_DIR" || {
        echo "Unable to access application directory: $SCRIPTS_DIR" | tee -a "$LOGS_FILE"
        exit 1
    }

    if [ -f package.json ]; then
        npm install &>> "$LOGS_FILE"
        validate $? "Installing Node.js dependencies"
    else
        echo "package.json not found in $SCRIPTS_DIR" | tee -a "$LOGS_FILE"
        exit 1
    fi
}

# Execute functions
check_root
nodejs_setup

echo -e "$(timestamp) [INFO] ==== Script Execution Completed =====" | tee -a "$LOGS_FILE"
```