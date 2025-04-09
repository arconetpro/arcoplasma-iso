#!/bin/bash
#set -e
#tput setaf 0 = black 
#tput setaf 1 = red 
#tput setaf 2 = green
#tput setaf 3 = yellow 
#tput setaf 4 = dark blue 
#tput setaf 5 = purple
#tput setaf 6 = cyan 
#tput setaf 7 = gray 
#tput setaf 8 = light blue
##################################################################################################################
# Author	:	Erik Dubois
# Website	:	https://www.erikdubois.be
# Website	:	https://www.arcolinux.info
# Website	:	https://www.arcolinux.com
# Website	:	https://www.arcolinuxd.com
# Website	:	https://www.arcolinuxb.com
# Website	:	https://www.arcolinuxiso.com
# Website	:	https://www.arcolinuxforum.com
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################
# Funtions

clean_cache() {
    if [[ "$1" == "yes" ]]; then
    	echo "##################################################################"
    	tput setaf 2
        echo "Cleaning the cache from /var/cache/pacman/pkg/"
        tput sgr0
        echo "##################################################################"
        yes | sudo pacman -Scc
    elif [[ "$1" == "no" ]]; then
        echo "Skipping cache cleaning."
    else
        echo "Invalid option. Use: clean_cache yes | clean_cache no"
    fi
}

remove_buildfolder() {

    if [[ -z "$buildFolder" ]]; then
        echo "Error: \$buildFolder is not set. Please define it before using this function."
        return 1
    fi

    if [[ "$1" == "yes" ]]; then
        if [[ -d "$buildFolder" ]]; then
        	echo "##################################################################"
    		tput setaf 3
            echo "Deleting the build folder ($buildFolder) - this may take some time..."
            tput sgr0
            sudo rm -rf "$buildFolder"
            echo "##################################################################"
        else
        	echo "##################################################################"
            echo "No build folder found. Nothing to delete."
            echo "##################################################################"
        fi
    elif [[ "$1" == "no" ]]; then
        echo "Skipping build folder removal."
    else
        echo "Invalid option. Use: remove_buildfolder yes | remove_buildfolder no"
    fi
}

installed_dir=$(dirname $(readlink -f $(basename `pwd`)))

echo
echo "################################################################## "
tput setaf 3
echo "Message"
echo
echo "Do not run this file as root or add sudo in front"
echo "Run this script as a user"
tput sgr0
echo "################################################################## "
echo

sleep 3

# message for BTRFS 
if 	lsblk -f | grep btrfs > /dev/null 2>&1 ; then
	echo
	echo "################################################################## "
	tput setaf 3
	echo "Message"
	echo
    echo "This script may cause issues on a Btrfs filesystem"
    echo "Make backups before continuing"
    echo "Continu at your own risk"
    echo
    echo "Press CTRL + C to stop the script now"
    tput sgr0
    echo
    for i in $(seq 10 -1 0); do
    	echo -ne "Continuing in $i seconds... \r"
    	sleep 1
    done
    echo
fi

# any distro without our keys and mirrors
if pacman -Q arcolinux-keyring &>/dev/null && pacman -Q arcolinux-mirrorlist-git &>/dev/null; then

	
	echo "################################################################## "
	tput setaf 2
	echo "ArcoLinux keyring and ArcoLinux mirrors are both installed"
	tput sgr0
	echo "################################################################## "
	
else
	echo
	echo "################################################################## "
	tput setaf 3
	echo "Installing ArcoLinux keyring and mirrors"
    echo "as we are missing the packages for ArcoLinux keys and mirrors"
    echo "You can remove them later with pacman -R ..."
    tput sgr0
    echo "################################################################## "
    
    bash "$installed_dir/get-the-keys-and-mirrors-arcolinux.sh"
    
fi

echo
echo "################################################################## "
tput setaf 2
echo "Phase 1 : "
echo "- Setting General parameters"
tput sgr0
echo "################################################################## "
echo

	#Let us set the desktop"
	#First letter of desktop is small letter

	desktop="plasma"

	arcolinuxVersion='v25.05.01'

	isoLabel='arcoplasma-'$arcolinuxVersion'-x86_64.iso'

	# setting of the general parameters
	archisoRequiredVersion="archiso 83-1"
	buildFolder=$HOME"/arcoplasma-build"
	outFolder=$HOME"/arcoplasma-Out"

	# If you want to add packages from the chaotics-aur repo then
	# change the variable to true and add the package names
	# that are hosted on chaotics-aur in the packages.x86_64 at the bottom

	chaoticsrepo=true

	if [[ "$chaoticsrepo" == "true" ]]; then
	    if pacman -Q chaotic-keyring &>/dev/null && pacman -Q chaotic-mirrorlist &>/dev/null; then
	        echo "################################################################## "
			tput setaf 2
			echo "Chaotic keyring and mirrorlist are both installed"
			tput sgr0
			echo "################################################################## "
	    else
	        if [[ -f "$installed_dir/get-the-keys-and-mirrors-chaotic-aur.sh" ]]; then
	        	echo "################################################################## "
				tput setaf 3
				echo "Installing both Chaotic packages as we are missing"
				echo "chaotic-keyring and chaotic-mirrorlist"
    			echo "You can remove them later with pacman -R ..."
				tput sgr0
				echo "################################################################## "
	            bash "$installed_dir/get-the-keys-and-mirrors-chaotic-aur.sh"
	        else
		        echo "################################################################## "
				tput setaf 1
				echo "Error: Installation script not found at $installed_dir"
				tput sgr0
				echo "################################################################## "          
	            exit 1
	        fi
	    fi
	fi
	
	# If you are ready to use your personal repo and personal packages
	# https://arcolinux.com/use-our-knowledge-and-create-your-own-icon-theme-combo-use-github-to-saveguard-your-work/
	# 1. set variable personalrepo to true in this file (default:false)
	# 2. change the file personal-repo to reflect your repo
	# 3. add your applications to the file packages-personal-repo.x86_64

	personalrepo=false

echo
echo "################################################################## "
tput setaf 2
echo "Phase 2 :"
echo "- Checking if archiso/grub is installed"
echo "- Saving current archiso version to readme"
tput sgr0
echo "################################################################## "
echo

	package="archiso"

	#----------------------------------------------------------------------------------

	#checking if application is already installed or else install
	if pacman -Qi $package &> /dev/null; then

			echo "$package is already installed"

	else

		echo "################################################################"
		echo "######### Installing $package with pacman"
		echo "################################################################"

		sudo pacman -S --noconfirm $package

	fi

	# Just checking if installation was successful
	if pacman -Qi $package &> /dev/null; then

		echo 

	else

		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "!!!!!!!!!  "$package" has NOT been installed"
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		exit 1
	fi

	package="grub"

	#----------------------------------------------------------------------------------

	#checking if application is already installed or else install
	if pacman -Qi $package &> /dev/null; then

			echo "$package is already installed"

	else

		echo "################################################################"
		echo "######### Installing $package with pacman"
		echo "################################################################"

		sudo pacman -S --noconfirm $package

	fi

	# Just checking if installation was successful
	if pacman -Qi $package &> /dev/null; then

		echo

	else

		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "!!!!!!!!!  "$package" has NOT been installed"
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		exit 1
	fi

	archisoVersion=$(pacman -Q archiso)

	# Saving current archiso version to readme
	sed -i "s/\(^archiso-version=\).*/\1$archisoVersion/" ../archiso.readme

	# overview
	
	echo "################################################################## "
	tput setaf 2
	echo "Overview"
	tput sgr0
	echo "################################################################## "
	echo "Building the desktop                   : "$desktop
	echo "Building version                       : "$arcolinuxVersion
	echo "Iso label                              : "$isoLabel
	echo "Do you have the right archiso version? : "$archisoVersion
	echo "What is the required archiso version?  : "$archisoRequiredVersion
	echo "Build folder                           : "$buildFolder
	echo "Out folder                             : "$outFolder
	echo "################################################################## "
	echo

	if [ "$archisoVersion" == "$archisoRequiredVersion" ]; then
		tput setaf 2
		echo "##################################################################"
		echo "Archiso has the correct version. Continuing ..."
		echo "##################################################################"
		tput sgr0
	else
		tput setaf 1
		echo "###################################################################################################"
		echo "It is recommended to always use the latest version of Archiso and update it as needed."
		echo "###################################################################################################"
		tput sgr0
	fi

echo
echo "################################################################## "
tput setaf 2
echo "Phase 3 :"
echo "- Deleting the build folder if one exists"
echo "- Copying the Archiso folder to build folder"
tput sgr0
echo "################################################################## "
echo

	remove_buildfolder yes
	echo
	echo "Copying the Archiso folder to build work"
	echo
	mkdir $buildFolder
	cp -r ../archiso $buildFolder/archiso

echo "################################################################## "
tput setaf 2
echo "Phase 4 :"
echo "- Deleting any files in /etc/skel"
echo "- Getting the last version of bashrc in /etc/skel"
echo "- Removing the old packages.x86_64 file from build folder"
echo "- Copying the new packages.x86_64 file to the build folder"
echo "- Add our own personal repo + add your packages to packages-personal-repo.x86_64"
echo "- Adding chaotics-repo"
tput sgr0
echo "################################################################## "
echo

	echo "Deleting any files in /etc/skel"
	rm -rf $buildFolder/archiso/airootfs/etc/skel/.* 2> /dev/null
	echo

	echo "Getting the last version of bashrc in /etc/skel"
	echo
	wget https://raw.githubusercontent.com/arcolinux/arcolinux-root/master/etc/skel/.bashrc-latest -O $buildFolder/archiso/airootfs/etc/skel/.bashrc

	echo "Removing the old packages.x86_64 file from build folder"
	rm $buildFolder/archiso/packages.x86_64
	rm $buildFolder/archiso/packages-personal-repo.x86_64
	echo

	echo "Copying the new packages.x86_64 file to the build folder"
	cp -f ../archiso/packages.x86_64 $buildFolder/archiso/packages.x86_64
	echo

	if [ $personalrepo == true ]; then
		echo "Adding packages from your personal repository - packages-personal-repo.x86_64"
		printf "\n" | sudo tee -a $buildFolder/archiso/packages.x86_64
		cat ../archiso/packages-personal-repo.x86_64 | sudo tee -a $buildFolder/archiso/packages.x86_64
	fi

	if [ $personalrepo == true ]; then
		echo "Adding our own repo to /etc/pacman.conf"
		printf "\n" | sudo tee -a $buildFolder/archiso/pacman.conf
		printf "\n" | sudo tee -a $buildFolder/archiso/airootfs/etc/pacman.conf
		cat personal-repo | sudo tee -a $buildFolder/archiso/pacman.conf
		cat personal-repo | sudo tee -a $buildFolder/archiso/airootfs/etc/pacman.conf
	fi

	if [ $chaoticsrepo == true ]; then
		if ! grep -q "chaotic-aur" $buildFolder/archiso/airootfs/etc/pacman.conf; then
			echo
			echo "Adding our chaotics repo to /etc/pacman.conf"
			printf "\n" | sudo tee -a $buildFolder/archiso/pacman.conf
			printf "\n" | sudo tee -a $buildFolder/archiso/airootfs/etc/pacman.conf
			cat chaotics-repo | sudo tee -a $buildFolder/archiso/pacman.conf
			cat chaotics-repo | sudo tee -a $buildFolder/archiso/airootfs/etc/pacman.conf
		else
			echo "Chaotic repo already in /etc/pacman.conf"
		fi
	fi

	if [ $chaoticsrepo == false ]; then
		echo "Adding our chaotics repo to /etc/pacman.conf"
		printf "\n" | sudo tee -a $buildFolder/archiso/pacman.conf
		printf "\n" | sudo tee -a $buildFolder/archiso/airootfs/etc/pacman.conf
		cat no-chaotics-repo | sudo tee -a $buildFolder/archiso/pacman.conf
		cat no-chaotics-repo | sudo tee -a $buildFolder/archiso/airootfs/etc/pacman.conf
	fi

	echo
	echo "Adding the content of the /personal folder"
	echo
	cp -rf ../personal/ $buildFolder/archiso/airootfs/

	if test -f $buildFolder/archiso/airootfs/personal/.gitkeep ; then
		echo
		rm $buildFolder/archiso/airootfs/personal/.gitkeep
		# .gitkeep is now removed"
		echo
    fi

echo
echo "################################################################## "
tput setaf 2
echo "Phase 5 : "
echo "- Adding time to /etc/dev-rel"
echo "- Clean cache"
tput sgr0
echo "################################################################## "
echo

	echo "Adding time to /etc/dev-rel"
	date_build=$(date -d now)
	echo "Iso build on : "$date_build
	sudo sed -i "s/\(^ISO_BUILD=\).*/\1$date_build/" $buildFolder/archiso/airootfs/etc/dev-rel

	# cleaning cache yes or no
	echo
	clean_cache no

echo
echo "################################################################## "
tput setaf 2
echo "Phase 7 :"
echo "- Building the iso - this can take a while - be patient"
tput sgr0
echo "################################################################## "
echo

	[ -d $outFolder ] || mkdir $outFolder
	cd $buildFolder/archiso/
	sudo mkarchiso -v -w $buildFolder -o $outFolder $buildFolder/archiso/

echo
echo "###################################################################"
tput setaf 2
echo "Phase 8 :"
echo "- Creating checksums"
echo "- Copying pgklist"
tput sgr0
echo "###################################################################"
echo

	cd $outFolder

	echo "Creating checksums for : "$isoLabel
	echo "##################################################################"
	echo
	echo "Building sha1sum"
	echo "########################"
	sha1sum $isoLabel | tee $isoLabel.sha1
	echo "Building sha256sum"
	echo "########################"
	sha256sum $isoLabel | tee $isoLabel.sha256
	echo "Building md5sum"
	echo "########################"
	md5sum $isoLabel | tee $isoLabel.md5
	echo
	echo "Moving pkglist.x86_64.txt"
	echo "########################"
	cp $buildFolder/iso/arch/pkglist.x86_64.txt  $outFolder/$isoLabel".pkglist.txt"

echo
echo "##################################################################"
tput setaf 2
echo "Phase 9 :"
echo "- Removing the buildfolder or not"
tput sgr0
echo "################################################################## "
echo

	echo "Deleting the build folder if one exists - takes some time"
	remove_buildfolder no

echo
echo "##################################################################"
tput setaf 2
echo "DONE"
echo "- Check your out folder :"$outFolder
tput sgr0
echo "################################################################## "
echo
