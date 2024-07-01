#!/bin/bash

# Define file paths
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"
INPUT_FILE=$1

# Ensure secure directory for passwords
mkdir -p /var/secure
chmod 700 /var/secure

# Function to generate random password
generate_password() {
    tr -dc A-Za-z0-9 </dev/urandom | head -c 12
}

# Ensure log file exists
touch $LOG_FILE
chmod 644 $LOG_FILE

# Ensure password file exists
touch $PASSWORD_FILE
chmod 600 $PASSWORD_FILE

# Read input file
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Input file not found!" | tee -a $LOG_FILE
    exit 1
fi

# Process each line in the input file
while IFS=";" read -r username groups; do
    # Trim whitespaces
    username=$(echo $username | xargs)
    groups=$(echo $groups | xargs)

    # Check if user already exists
    if id -u "$username" >/dev/null 2>&1; then
        echo "User $username already exists. Skipping." | tee -a $LOG_FILE
        continue
    fi

    # Create personal group for the user
    groupadd "$username"

    # Create user with personal group
    useradd -m -g "$username" "$username"
    if [[ $? -ne 0 ]]; then
        echo "Failed to create user $username." | tee -a $LOG_FILE
        continue
    fi

    # Create additional groups and add user to them
    IFS=',' read -ra ADDR <<< "$groups"
    for group in "${ADDR[@]}"; do
        group=$(echo $group | xargs)
        if ! getent group "$group" >/dev/null; then
            groupadd "$group"
        fi
        usermod -aG "$group" "$username"
    done

    # Generate random password and set it
    password=$(generate_password)
    echo "$username:$password" | chpasswd

    # Log user creation
    echo "Created user $username with groups $groups." | tee -a $LOG_FILE
    echo "$username,$password" >> $PASSWORD_FILE
done < "$INPUT_FILE"

echo "User creation process completed." | tee -a $LOG_FILE
