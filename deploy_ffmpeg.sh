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

# installers #
Val_Mkdir_all() {
	echo_process "mkdir -p $FF_DIRS" "Making directories";
}

Val_AptInstall_all() {
	silent_echo_process "apt-get update" "Packages update";
	silent_echo_process "apt-get upgrade" "Packages upgrade";
	silent_echo_process "apt-get -y install autoconf automake build-essential cmake git-core libass-dev libfreetype6-dev libsdl2-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo wget zlib1g-dev" "Installing packages";
}

Val_Install_NASM() {
	echo_process "cd $FF_DIR_SOURCE" "Installing NASM [1]"
	echo_process "wget https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.bz2" "Installing NASM [2]"
	silent_echo_process "tar xjvf nasm-2.13.03.tar.bz2" "Installing NASM [3]"
	echo_process "cd nasm-2.13.03" "Installing NASM [4]"
	silent_echo_process "./autogen.sh" "Installing NASM [5]"
	PATH="$FF_DIR_BIN:$PATH"
	silent_echo_process " ./configure --prefix=$FF_DIR_BUILD --bindir=$FF_DIR_BIN" "Installing NASM [6]"
	silent_echo_process "make -j4" "Installing NASM [7]" 
	echo_process "make install" "Installing NASM [8]"
}

Val_Install_x264() {
	echo_process "cd $FF_DIR_SOURCE" "Installing libx264 [1]"
	echo_process "git clone --depth 1 https://git.videolan.org/git/x264" "Installing libx264 [2]" 
	echo_process "cd x264" "Installing libx264 [3]"
	PATH="$FF_DIR_BIN:$PATH" 
	PKG_CONFIG_PATH="$FF_DIR_BUILD/lib/pkgconfig"
	silent_echo_process "./configure --prefix=$FF_DIR_BUILD --bindir=$FF_DIR_BIN --enable-static --enable-pic" "Installing libx264 [4]"
	silent_echo_process "make -j4" "Installing libx264 [5]"
	echo_process "make install" "Installing libx264 [6]"
}

Val_Install_ffmpeg() {
	echo_process "cd $FF_DIR_SOURCE" "Installing ffmpeg [1]"
	if ! [ -d ffmpeg ]; then 
	echo_process "git clone --depth 1 https://github.com/FFmpeg/FFmpeg.git ffmpeg" "Installing ffmpeg [2]"; 
	else echo_red "Error: ffmpeg already exists. Trying to compile..."; fi
	echo_process "cd ffmpeg" "Installing ffmpeg [3]"
	PATH="$FF_DIR_BIN:$PATH" 
	PKG_CONFIG_PATH="$FF_DIR_BUILD/lib/pkgconfig"
	get_current_step_number; 
	local ff_step_i=$?; 
	echo_yellow "[Step $ff_step_i]: Started! # Installing ffmpeg [4]"; 
	./configure --prefix="$FF_DIR_BUILD" --pkg-config-flags="--static" --extra-cflags="-I$FF_DIR_BUILD/include" --extra-ldflags="-L$FF_DIR_BUILD/lib" --extra-libs="-lpthread -lm" --bindir="$FF_DIR_BIN" --enable-gpl --enable-libx264 #"Installing ffmpeg [5]"
	echo_green "[Step $ff_step_i]: Done!";
	PATH=$FF_DIR_BIN:$PATH
	silent_echo_process "make -j4" "Installing ffmpeg [5]"
	echo_process "make install" "Installing ffmpeg [6]"
	silent_echo_process "hash -r" "Installing ffmpeg [7]"
}

# install types #
Val_InstallType_full_setup() {
	Val_Mkdir_all
	Val_AptInstall_all
	Val_Install_NASM
	Val_Install_x264 
	Val_Install_ffmpeg 
}
Val_Install_libs() {
	echo_yellow "What libs you want to install?"
	echo_yellow "(1) All"
	echo_yellow "(2) x264"	
	echo_yellow "(3) NASM"
	echo_yellow "Enter number below."
	read -p "type < " _Type
	case $_Type in
	1) Val_Install_x264
	Val_Install_NASM ;; 
	2) Val_Install_x264 ;;
	3) Val_Install_NASM ;;
	*) echo_red "Wrong \$type" ;; esac
}

# Main function definition #
Val_Main() {
	echo_yellow "WELLCOME TO FFMPEG DEPLOY SCRIPT"
	echo_yellow "Choose Installation type:"
	echo_yellow "(1) Full setup"
	echo_yellow "(2) Setup ffmpeg only"	
	echo_yellow "(3) Setup libs only"
	echo_yellow "(4) Clean ffmpeg"
	echo_yellow "Enter number below."

	read -p "type < " _Type
	case $_Type in 
	1) Val_InstallType_full_setup ;;
	2) Val_Install_ffmpeg ;;
	3) Val_Install_libs ;;
	4) sh $HOMEDIR/Desktop/FFMPEGdeploy/ffmpeg_clean.sh ;;
	*) echo_red "Wrong \$type" ;; esac
}

# Execute Main function #
Val_Main
