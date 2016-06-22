#!/bin/bash

echo " Installing Laravel Project ... "

#config
CONFIGFILE=".make_config"
PROCESS=$1
#function

function askConfig {

	echo -n "Git or mercurial ? (git/hg) > "
        read VERSIONNING_PROMPT

    echo -n "Repository url ? (https:// .... .git) > "
        read REPOSITORY_PROMPT

	echo -n "User ? (www-data / ...) > "
        read USERC_PROMPT

    echo -n "Group ? ( www-data / ... ) > "
        read GROUPC_PROMPT

    createConfigContent $VERSIONNING_PROMPT $REPOSITORY_PROMPT $USERC_PROMPT $GROUPC_PROMPT
}

function createConfigContent() {

	echo "VERSIONNING=$1" >> $CONFIGFILE
	echo "REPOSITORY=$2" >> $CONFIGFILE
	echo "USERC=$3" >> $CONFIGFILE
	echo "GROUPC=$4" >> $CONFIGFILE

}

function checkSoftware {


	if ! command -v composer 2>/dev/null  2>&1 ; then
		wget https://getcomposer.org/composer.phar
		mv composer.phar /usr/bin/composer
		chmod +x /usr/bin/composer
	fi

	if ! command -v git 2>/dev/null  2>&1; then
        apt-get install git
    fi
    if ! command -v hg 2>/dev/null  2>&1; then
        apt-get install mercurial
    fi

	command -v git >/dev/null 2>&1 || { echo >&2 "Git is required.  Aborting."; exit 1; }
	command -v hg >/dev/null 2>&1 || { echo >&2 "Mercurial/hg is required.  Aborting."; exit 1; }
	command -v composer >/dev/null 2>&1 || { echo >&2 "Composer is required.  Aborting."; exit 1; }

}

#retrieve config
echo "Checking for required software ..."
checkSoftware

echo "Checking for configuration ..."
if [ ! -f $CONFIGFILE ]
then
	echo "No config file found, I will ask you some questions (You can edit the config file after if needed at /$CONFIGFILE "
	askConfig
fi

echo "Reading config from $CONFIGFILE...." >&2
. $CONFIGFILE


echo VERSIONNING=$VERSIONNING
echo REPOSITORY=$REPOSITORY
echo USERC=$USERC
echo GROUPC=$GROUPC


# process function

function updateRepository {

	if [ "$VERSIONNING" = "git" ];
	then
		git pull
	elif [ "$VERSIONNING" = "hg" ];
	then
		hg pull && hg update
	else
		echo "Only git and mercurial (hg) are supported. Update $CONFIGFILE ! "
		exit 1;
	fi
}

function cloneRepository {

	if [ "$VERSIONNING" = "git" ];
	then

		git init
		git remote add origin $REPOSITORY
		git fetch
		git checkout -t origin/master
	elif [ "$VERSIONNING" = "hg" ];
	then
		hg init
		hg pull $REPOSITORY
	else
		echo "Only git and mercurial (hg) are supported. Update $CONFIGFILE ! "
		exit;
	fi

}

#process


if [ "$PROCESS" = "update" ]
 then
	echo "Updating project..."

	apt-get update && apt-get upgrade

	updateRepository

	chmod 0777 -R bootstrap

	php artisan migrate

	php artisan cache:clear

	chown -R $USERC:$GROUPC *

	composer update


elif [ "$PROCESS" = "install" ]
 then
	echo "Installing project"

	apt-get update && apt-get upgrade

	cloneRepository

	cp .env.example .env

	nano .env
	
	chmod 0777 -R bootstrap

	composer install

	chmod 0777 -R bootstrap

	php artisan key:generate

	php artisan migrate

	php artisan db:seed

	chown -R $USERC:$GROUPC *

	composer update

else
	echo "Arg 1 missing"

	echo "Usage: ./make [install|update]"
	exit 1;
fi
