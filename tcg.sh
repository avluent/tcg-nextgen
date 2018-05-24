#!/bin/bash 

### VARIABLES ### 

# Global Variables

# Container Image Names
CONT_SERV=
CONT_PHP=
CONT_DB=
CONT_MAIL=

# Docker Command Variables
DOCKER_USER=docker
DOCKER_GROUP=docker
DOCKER_SHELL="sudo -u $DOCKER_USER "
DOCKER_DIR=/usr/local/share/tcg

### FUNCTIONS ###

# Help Function
help() {
	printf '\n\033[1mTennisclub Gemmrigheim - Operational Instructions\033[0m\n\n'
	printf 'Enter the command for starting the shell script, '
	printf 'followed by an option.\n'
	printf 'Example: $ sudo ./tcg.sh help\n\n'
	printf 'We recommend first executing: \n$ sudo ./tcg.sh setup\n'
	printf 'After this action, you will be able to run the following commands '
	printf 'like: \n$ sudo tcg <option n>\n\n'
	printf 'The list of options are categorized into multiple groups:\n\n'
	printf '1.) Container deployment: Creating and launching the service containers\n'
	printf '2.) Starting containers: Starting containers when already deployed\n'
	printf '3.) Restarting containers and services: In case of trouble\n'
	printf '4.) Stopping containers: When a service should be terminated or killed\n'
	printf '5.) Removing containers: When a service container should be removed completely\n'
	printf '6.) Others\n\n\n'	
	printf '%-25s - %-30s \n' 'deploy' 'Deploy and start all containers at once'
	printf '%-25s - %-30s \n' 'deployWebserver' 'Deploy and start the webserver'
	printf '%-25s - %-30s \n' 'deployDB' 'Deploy and start the postgreSQL database'
	printf '%-25s - %-30s \n\n' 'deployMail' 'Deploy and start the e-mail server\n'
	printf '%-25s - %-30s \n' 'start' 'Start all containers at once'
	printf '%-25s - %-30s \n' 'startWebserver' 'Start the webserver'
	printf '%-25s - %-30s \n' 'startDB' 'Start the postgreSQL database'
	printf '%-25s - %-30s \n\n' 'startMail' 'Start the e-mail server\n'
	printf '%-25s - %-30s \n' 'restart' 'Restart all containers at once'
	printf '%-25s - %-30s \n' 'restartWebserver' 'Restart the webserver'
	printf '%-25s - %-30s \n' 'restartDB' 'Restart the postgreSQL database'
	printf '%-25s - %-30s \n\n' 'restartMail' 'Restart the e-mail server\n'
	printf '%-25s - %-30s \n' 'stop' 'Stop all containers at once'
	printf '%-25s - %-30s \n' 'stopWebserver' 'Stop the webserver'
	printf '%-25s - %-30s \n' 'stopDB' 'Stop the postgreSQL database'
	printf '%-25s - %-30s \n\n' 'stopMail' 'Stop the e-mail server\n'
	printf '%-25s - %-30s \n' 'remove' 'Remove all containers at once'
	printf '%-25s - %-30s \n' 'removeWebserver' 'Remove the webserver'
	printf '%-25s - %-30s \n' 'removeDB' 'Remove the postgreSQL database'
	printf '%-25s - %-30s \n\n' 'removeMail' 'Remove the e-mail server\n'
	printf '%-25s - %-30s \n' 'setup' 'Setting up the (Docker) Environment'
	printf '%-25s - %-30s \n' 'restartDocker' 'Emergency restart of the Docker service'
	printf '%-25s - %-30s \n' 'status' 'Returns a status of all containers'
}

# Deployment Functions
deploy(){
	deployWebserver
	deployDB
	deployMail
}
deployWebserver() {
	log ${FUNCNAME[0]} 'Deploying the webserver...'
	# Run the docker command as Docker user
	$DOCKER_SHELL docker run --name=web -d -v $DOCKER_DIR/web/log:/var/log/nginx -p 8000:80 -p 4430:443 nginx
	log ${FUNCNAME[0]} "Webserver is deployed successfully..."
}
deployDB() {
	log ${FUNCNAME[0]} 'Deploying the Database...'
}
deployMail() {
	log ${FUNCNAME[0]} 'Deploying the mailserver...'
}

# Start Functions
start(){
	startWebserver
	startDB
	startMail
}
startWebserver() {
	log ${FUNCNAME[0]} 'Starting the webserver...'
}
startDB() {
	log ${FUNCNAME[0]} 'Starting the Database...'
}
startMail() {
	log ${FUNCNAME[0]} 'Starting the mailserver...'
}

# Restart Functions
restart(){
	restartWebserver
	restartDB
	restartMail
}
restartWebserver() {
	log ${FUNCNAME[0]} 'Restarting the webserver...'
}
restartDB() {
	log ${FUNCNAME[0]} 'Restarting the Database...'
}
restartMail() {
	log ${FUNCNAME[0]} 'Restarting the mailserver...'
}


# Stop Functions
stop(){
	stopWebserver
	stopDB
	stopMail
}
stopWebserver() {
	log ${FUNCNAME[0]} 'Stopping the webserver...'
}
stopDB() {
	log ${FUNCNAME[0]} 'Stopping the Database...'
}
stopMail() {
	log ${FUNCNAME[0]} 'Stopping the mailserver...'
}


# Removal Functions
remove(){
	removeWebserver
	removeDB
	removeMail
}
removeWebserver() {
	log ${FUNCNAME[0]} 'Removing the webserver...'
} 
removeDB() {
	log ${FUNCNAME[0]} 'Removing the Database...'
}
removeMail() {
	log ${FUNCNAME[0]} 'Removing the mailserver...'
}


# Other Functions
setup() {
	log ${FUNCNAME[0]} 'Starting Docker setup...'
	#Install Docker first
	if dpkg -s docker.io | grep -q installed ; then
		log ${FUNCNAME[0]} 'Docker is already installed'
	else
		log ${FUNCNAME[0]} "Starting the Docker Installation..."
		apt-get update
		apt-get -qq install -y docker.io
		systemctl enable docker
		log ${FUNCNAME[0]} 'Installation done and Enabled on system start.'
	fi
	#Create Group if not yet exists
	if  cat /etc/group | grep -q $DOCKER_GROUP ; then
		log ${FUNCNAME[0]} 'Group '$DOCKER_GROUP' already exists'
	else
		groupadd $DOCKER_GROUP
		log ${FUNCNAME[0]} 'Group '$DOCKER_GROUP' was added successfully'
	fi
	#Create user if not exist and add to Docker group
	if  cat /etc/passwd | grep -q $DOCKER_USER ;then
		log ${FUNCNAME[0]} 'Docker user already available on the system'
	else
		# Create the Docker working DIR
		mkdir $DOCKER_DIR
		log ${FUNCNAME[0]} "Working Directory Created..."	

		# Add the user
		useradd -r -d $DOCKER_DIR -g $DOCKER_GROUP -G sudo -s /bin/bash $DOCKER_USER
		log ${FUNCNAME[0]} "Docker user created..."	

		# Owning the folders
		chown -R $DOCKER_USER:$DOCKER_USER $DOCKER_DIR

		# Setting the password
		log ${FUNCNAME[0]} "Enter a password for the Docker user..."	
		passwd $DOCKER_USER
		log ${FUNCNAME[0]} 'Password was set correctly...'

		# Output the Done message
		log ${FUNCNAME[0]} "SetupDocker done..."
	fi

}
restartDocker() {
	log ${FUNCNAME[0]} 'Emergency restart of the Docker Service...'
	systemctl restart docker
	log ${FUNCNAME[0]} 'Successfully restarted the Docker system service'
}
status() {
	if  cat /etc/passwd | grep -q $DOCKER_USER;then
		systemctl status docker | grep active
		$DOCKER_SHELL docker info
		log ${FUNCNAME[0]} 'Getting the Docker swarm status information...\n'
		$DOCKER_SHELL docker ps
	else
		log ${FUNCNAME[0]} "Docker user not installed. Type setupDocker first..."
	fi
}
log() {
	echo $(date) '-' $1 '-' $2 >> tcg_log.txt
	echo $2
}	

### RUNTIME ###
# Execute input variables only
if [ ! $1 ]; then
	log ${FUNCNAME[0]} 'Please add an argument when running this script.' \
		'For more information, type "./tcg.sh help"'
else
	# Run all arguments
	for ARG in $*; do
		$ARG
	done
fi
