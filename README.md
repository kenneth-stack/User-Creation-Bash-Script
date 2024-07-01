<!DOCTYPE html>
<html lang="en">
<head>
</head>
<body>
    <h1>Automating User Creation and Management with a Bash Script</h1>
    <p>As a SysOps engineer, managing user accounts and groups is a routine but crucial task. Automating this process not only saves time but also reduces the potential for errors. In this article, we'll walk through a bash script that reads user information from a text file, creates users and their groups, sets up home directories, generates random passwords, logs actions, and stores passwords securely.</p>

<h2>The Script: <code>create_users.sh</code></h2>

<h3>Features:</h3>
    <ul>
        <li><strong>Input File Processing:</strong> The script takes a text file where each line contains a username and a list of groups, separated by a semicolon (<code>;</code>). Example:
            
            light;sudo,dev,www-data
            idimma;sudo
            mayowa;dev,www-data
            
 </li>
        <li><strong>User and Group Creation:</strong> For each user, the script creates a personal group with the same name as the username and adds the user to the specified groups.</li>
        <li><strong>Home Directory Setup:</strong> Home directories are created automatically with appropriate permissions.</li>
        <li><strong>Random Password Generation:</strong> A secure random password is generated for each user.</li>
        <li><strong>Logging Actions:</strong> All actions performed by the script are logged to <code>/var/log/user_management.log</code>.</li>
        <li><strong>Secure Password Storage:</strong> Usernames and passwords are stored in <code>/var/secure/user_passwords.txt</code> with restricted access permissions.</li>
    </ul>

<h3>Script Breakdown:</h3>

 <h4>File Paths and Secure Directory Setup:</h4>
 
         LOG_FILE="/var/log/user_management.log"
         PASSWORD_FILE="/var/secure/user_passwords.txt"
         INPUT_FILE=$1
         mkdir -p /var/secure
         chmod 700 /var/secure

 <h4>Random Password Generation Function:</h4>
 
         generate_password() {
         tr -dc A-Za-z0-9 &lt;/dev/urandom | head -c 12
        }

 <h4>Log and Password File Initialization:</h4>
 
         touch $LOG_FILE
         chmod 644 $LOG_FILE
         touch $PASSWORD_FILE
         chmod 600 $PASSWORD_FILE

<h4>Processing the Input File:</h4>
    
    if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Input file not found!" | tee -a $LOG_FILE
    exit 1
    fi
    

    while IFS=";" read -r username groups; do
    username=$(echo $username | xargs)
    groups=$(echo $groups | xargs)
    

    if id -u "$username" &gt;/dev/null 2&gt;&1; then
        echo "User $username already exists. Skipping." | tee -a $LOG_FILE
        continue
    fi

    groupadd "$username"

    useradd -m -g "$username" "$username"
    if [[ $? -ne 0 ]]; then
        echo "Failed to create user $username." | tee -a $LOG_FILE
        continue
    fi

    IFS=',' read -ra ADDR &lt;&lt;&lt; "$groups"
    for group in "${ADDR[@]}"; do
        group=$(echo $group | xargs)
        if ! getent group "$group" &gt;/dev/null; then
            groupadd "$group"
        fi
        usermod -aG "$group" "$username"
    done

    password=$(generate_password)
    echo "$username:$password" | chpasswd

    echo "Created user $username with groups $groups." | tee -a $LOG_FILE
    echo "$username,$password" &gt;&gt; $PASSWORD_FILE
    done &lt; "$INPUT_FILE"

    echo "User creation process completed." | tee -a $LOG_FILE

 <p>This script ensures efficient user management and enhances security through automated processes. For more insights, explore further learning opportunities, check out the <a href="https://hng.tech/internship">HNG Internship</a> and <a href="https://hng.tech/premium">HNG Premium</a> website. you wont regret it</p>
</body>
</html>
