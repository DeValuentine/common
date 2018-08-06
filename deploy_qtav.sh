#/!/bin/bash

# Written by Valentine `GST Samara`

##################################################################
##                    `Obvious things:`				##	
##################################################################
##  Val_Get_* 		= download *;				##	
##  Val_Install_* 	= install *;				##
##  Val_AptInstall_* 	= install package * using apt; 		##		
##  Val_Mkdir_* 	= make directiory *;			##
##################################################################


# pre-requisites #
	#=Change to adapt script=#
	USERNAME="valentine"
	#========================#
HOMEDIR="/home/$USERNAME"
FF_DIR_SOURCE="$HOMEDIR/FFMPEG/src"
FF_DIR_BUILD="$HOMEDIR/FFMPEG/build"
FF_DIR_BIN="$HOMEDIR/FFMPEG/bin"
FF_LOG_FILE="$HOMEDIR/logs/ffmpeg_deploy.log"
FF_DIRS="$FF_DIR_SOURCE $FF_DIR_BUILD $FF_DIR_BIN"

# print functions #
echo_log() { echo $1 >> $FF_LOG_FILE; }
echo_green()	{ echo "\033[32m### $1\033[0m"; echo_log "$1"; }
echo_red()	{ echo "\033[31m### $1\033[0m"; echo_log "$1"; }
echo_yellow()	{ echo "\033[33m### $1\033[0m"; echo_log "$1"; }
echo_blue()	{ echo "\033[34m### $1\033[0m"; echo_log "$1"; }

# common functions #
do_command_silent_with_check() { 
	local  __resultvar=$2;
	echo_blue "Executing: $1";
	if $1 1>/dev/null
	then echo_green "->Command was executed successefull!";
	local  funcresult=0
	eval $__resultvar=$funcresult
	else echo_red "->ERROR! Command aborted!"; local  funcresult=100
	eval $__resultvar=$funcresult; fi
}

silent_do_or_die() { do_command_silent_with_check "$1" result;
	if ! [ $result -eq 0 ];
	then echo_red "->Process killed."; exit; fi
}

do_command_with_check() { 
	local  __resultvar=$2;
	echo_blue "Executing: $1";
	if $1 #1>/dev/null
	then echo_green "->Command was executed successefull!";
	local  funcresult=0
	eval $__resultvar=$funcresult
	else echo_red "->ERROR! Command aborted!"; local  funcresult=100
	eval $__resultvar=$funcresult; fi
}

do_or_die() { do_command_with_check "$1" result;
	if ! [ $result -eq 0 ];
	then echo_red "->Process killed."; exit; fi
}

current_step_number=0
get_current_step_number() {
	current_step_number=$(($current_step_number + 1))
	return $current_step_number
}

echo_process() { 
	get_current_step_number; 
	local step_i=$?; 
	echo_yellow "[Step $step_i]: Started! # $2"; 
	do_or_die "$1"; 
	echo_green "[Step $step_i]: Done!\n"; 
}

silent_echo_process() { 
	get_current_step_number; 
	local step_i=$?; 
	echo_yellow "[Step $step_i]: Started! # $2"; 
	silent_do_or_die "$1"; 
	echo_green "[Step $step_i]: Done!\n"; 
}

###################################################################
#
#	echo_process_va_args() { 
#		get_current_step_number; 
#		local step_i=$?; 
#		echo_yellow "[Step $step_i]: Started! # ${!#}"; 
#		while [ -n "$2" ]
#		do
#		do_or_die $1;
#		shift
#		done
#		echo_green "[Step $step_i]: Done!\n"; 
#	}
#
###################################################################

QTAVDIR="$HOMEDIR/qtav";

Val_Install_qtav() {
	apt-get install -y libopenal1 libopenal-dev libpulse-dev libva-dev libxv-dev libass-dev libegl1-mesa-dev;

	
	mkdir -p $QTAVDIR;
	cd $QTAVDIR;

	if ! [ -d sunxi ]; then
	git clone "https://github.com/linux-sunxi/cedarx-libs.git" sunxi; fi
	cd "sunxi/libcedarv/linux-armhf";
	make -j4;
	make install;
	cd ../../..;

	if ! [ -d "source" ]; then
	git clone "https://github.com/wang-bin/QtAV.git" "source";
	cd "source";
	git submodule update --init;
	cd ..;
	fi

	mkdir -p build;
	cd build;
	qmake ../source/QtAV.pro "CONFIG += recheck"
	make -j4	
		#cmake -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DQTDIR="$HOMEDIR/Qt/5.11.1/gcc_64" "../src"
		#ninja
		#ninja install;
	make install;
	sh sdk_install.sh;
}

Val_Install_libs() {
	sh deploy_ffmpeg.sh;
}

Val_InstallType_full_setup() {
	sh ffmpeg_clean.sh;
	Val_Install_libs;
	Val_Install_qtav;
}	

# Main function definition #
Val_Main() {
	echo_yellow "[QtAV] Deploy script. Choose Installation type:"
	echo_yellow "(1) Full setup"
	echo_yellow "(2) Setup QtAV only"	
	echo_yellow "(3) Setup libs only"
	echo_yellow "(4) Clean"
	echo_yellow "Enter number below."

	read -p "type < " _Type
	case $_Type in 
	1) Val_InstallType_full_setup ;;
	2) Val_Install_qtav ;;
	3) Val_Install_libs ;;
	4) sh qtav_clean.sh ;; 
	*) echo_red "Wrong \$type" ;; esac
}

# invoke main #
Val_Main;
