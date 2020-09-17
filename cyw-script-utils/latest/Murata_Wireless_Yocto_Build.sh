#!/bin/bash
VERSION=09172020

# Use colors to highlight pass/fail conditions.
RED='\033[1;31m' # Red font to flag errors
GRN='\033[1;32m' # Green font to flag pass
YLW='\033[1;33m' # Yellow font for highlighting
NC='\033[0m' # No Color

clear
#echo "12345678901234567890123456789012345678901234567890123456789012345678901234567890"

echo " "
echo "MURATA Custom i.MX Linux build using Yocto"
echo "=========================================="

echo " "
echo "1) Verifying Host Environment"
echo "-----------------------------"

# Get Linux distro; make sure it is "Ubuntu"
Linux_Distro=$(lsb_release -i -s)
if [ $Linux_Distro == "Ubuntu" ]; then
                echo -e "Murata: Verified Linux Distribution: " ${GRN}$Linux_Distro${NC}
else
                echo -e "${RED}Murata: Only Ubuntu Linux Distribution supported; not:${NC}" $Linux_Distro
                exit
fi

# Get Ubuntu release version; make sure it is either 16.04, 14.04 or 12.04.
Ubuntu_Release=$(lsb_release -r -s)
if [ $Ubuntu_Release == "16.04" ] || [ $Ubuntu_Release == "14.04" ] || [ $Ubuntu_Release == "12.04" ]; then
                echo -e "Murata: Verified Ubuntu Release:${NC}     " ${GRN}$Ubuntu_Release${NC}
else
                echo -e "${RED}Murata: Only Ubuntu versions 16.04, 14.04, and 12.04 are supported; not:" $Ubuntu_Release
		echo -e "Exiting script.....${NC}"
                exit
fi


# Ubuntu Distro and Version verified. Now add necessary commands.

# BSP directory
export BSP_DIR=`pwd`

echo " "
echo "2) Verifying Script Version"
echo "---------------------------"


GITHUB_PATH="\""https://github.com/bchen-murata/meta-murata-wireless.git"\""
META_MURATA_WIRELESS_GIT="https://github.com/bchen-murata/meta-murata-wireless.git"

echo "Fetching latest script from Murata Github."
echo "Cloning $GITHUB_PATH"
echo "Creating "\""meta-murata-wireless"\"" subfolder."


# check to see if there is already a folder with name, "meta-murata-wireless"
# if it is, then fetch the latest files
# else clone meta-murata-wireless
TEST_DIR_NAME=meta-murata-wireless
if [ -d "$TEST_DIR_NAME" ]; then
	cd $TEST_DIR_NAME/cyw-script-utils/latest
	git fetch --all 		--quiet
	git reset --hard origin/master 	--quiet
	git pull origin master 		--quiet
else
	git clone $META_MURATA_WIRELESS_GIT --quiet
	cd $TEST_DIR_NAME/cyw-script-utils/latest
fi

export SCRIPT_DIR=`pwd`
#echo "Latest folder path: $SCRIPT_DIR"

# Scan through the file Murata_Wireless_Yocto_Build.sh to fetch the Revision Information
COUNTER=0
input_file_path="$SCRIPT_DIR/Murata_Wireless_Yocto_Build.sh"

while IFS= read -r LATEST_VER
do
  COUNTER=$[$COUNTER +1]
  if [ "$COUNTER" = "2" ] ; then
  break
  fi
done < "$input_file_path"

cd $BSP_DIR

# read first and second line of Murata_Wireless_Yocto_Build.sh script
IFS== read FIRST_LINE LATEST_VER <<< $LATEST_VER

# Check for latest revision
if [ "$VERSION" = "$LATEST_VER" ]; then
	echo    "Latest:  $LATEST_VER"
	echo -e "Current: $VERSION${GRN}........PASS${NC}"
else
	echo    "Latest:  $LATEST_VER"
	echo -e "Current: ${YLW}$VERSION........MISMATCH${NC}"
	echo " "

        echo -n -e "Do you want to update build script? ${GRN}Y${NC}/${YLW}n${NC}: "
	read PROCEED_UPDATE_OPTION

	if [ "$PROCEED_UPDATE_OPTION" = "y" ] || [ "$PROCEED_UPDATE_OPTION" = "Y" ] || [ "$PROCEED_UPDATE_OPTION" = "" ]; then
		echo "Update to latest version using following copy command:"
		echo " "
		echo ""\$ "cp ./meta-murata-wireless/cyw-script-utils/latest/Murata_Wireless_Yocto_Build.sh ."
		echo " "
		echo -e "${YLW}Exiting script.....${NC}"
       		exit
	else
		echo " "
		echo -e "${YLW}CONTINUING WITH CURRENT SCRIPT.${NC}"
	fi
fi

# Initialize variables
BRANCH_RELEASE_OPTION=0
VIO_SIGNALING_OPTION=0
BUILD_1_8V_VIO_IMAGE=0
LINUX_SRC=""
LINUX_DEST=""
VIO_SIGNALING_STRING=""
CWD=""
MANDA_FMAC_INDEX="1"
KONG_FMAC_INDEX="2"
GAMERA_FMAC_INDEX="3"
LINUX_KERNEL_4_1_15=0
LINUX_KERNEL_4_9_123=1
LINUX_KERNEL_4_14_98=2
LINUX_KERNEL_5_4_24=3

DISTRO_NAME=fsl-imx-fb
IMAGE_NAME=core-image-base


echo " "
echo "3) Select Release Type"
echo "----------------------"

echo -e "a) Stable: Murata tested/verified release tag. ${GRN}Stable is the recommended default.${NC}"
echo " "
#echo "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
echo -e "b) Developer: Includes latest fixes on branch. ${YLW}May change at any time.${NC}"
echo " "

echo -n -e "Select ${GRN}Stable${NC} ( ${YLW}"\'"n"\'"=Developer${NC} )? ${GRN}Y${NC}/${YLW}n${NC}: "
read BRANCH_TAG_OPTION
if [ "$BRANCH_TAG_OPTION" = "y" ] || [ "$BRANCH_TAG_OPTION" = "Y" ] || [ "$BRANCH_TAG_OPTION" = "" ]; then
	BRANCH_TAG_OPTION="y"
	echo -e "${GRN}Stable release selected${NC}"
else
	BRANCH_TAG_OPTION="n"
	echo -e "${YLW}WARNING!!! Developer release selected${NC}"
fi

iMXYoctoRelease=""
YoctoBranch=""
fmacversion=""
fmacVersion
linuxVersion

iMXrockominimandaStableReleaseTag="imx-rocko-mini-manda_r2.2"
iMXrockominimandaDeveloperRelease="imx-rocko-mini-manda"

iMXrockominikongStableReleaseTag="imx-rocko-mini-kong_r1.0"
iMXrockominikongDeveloperRelease="imx-rocko-mini-kong"

iMXkrogothmandaStableReleaseTag="imx-krogoth-manda_r2.2"
iMXkrogothmandaDeveloperRelease="imx-krogoth-manda"

iMXsumomandaStableReleaseTag="imx-sumo-manda_r1.2"
iMXsumomandaDeveloperRelease="imx-sumo-manda"

iMXsumokongStableReleaseTag="imx-sumo-kong_r1.1"
iMXsumokongDeveloperRelease="imx-sumo-kong"


imxsumoYocto="4.14.98_2.3.0 GA"
imxrockominiYocto="4.9.123_2.3.0 GA"
imxkrogothYocto="4.1.15_2.0.0 GA"

#*************************************** For i.MX - start *****************************************
while true; do
  echo " "
  echo "4) Select "\""Linux Kernel"\"" "
  echo "-------------------------------------------------------"
  echo "|Entry|   Linux Kernel   | Yocto   |FMAC Supported    |"
  echo "|-----|------------------|---------|------------------|"
  echo "|  0  | 4.1.15_2.0.0     | krogoth | Manda            |"
  echo "|  1  | 4.9.123_2.3.0    | rocko   | Manda,Kong,Zigra |"
  echo "|  2  | 4.14.98_2.3.0    | sumo    | Manda,Kong,Zigra |"
  echo "|  3  | 5.4.24_2.1.0     | zeus    | Zigra            |"
  echo "-------------------------------------------------------"
  read -p "Select which entry? " LINUX_KERNEL

  case $LINUX_KERNEL in
    0)
      linuxVersion=4.1.15
      echo "linuxVersion=$linuxVersion"
      break
      ;;
    1)
      linuxVersion=4.9.123
      echo "linuxVersion=$linuxVersion"
      break
      ;;
    2)
      linuxVersion=4.14.98
      echo "linuxVersion=$linuxVersion"
      break
      ;;
    3)
      linuxVersion=5.4.24
      echo "linuxVersion=$linuxVersion"
      exit
      break
      ;;
    *)
      echo -e "${RED}That is not a valid choice, try again.${NC}"
      echo $'\n'
      ;;
  esac

done

echo " "
echo "5) Select "\""fmac"\"" version"
echo "------------------------"
MANDA_FMAC=""\""manda"\""  (v4.14)"
KONG_FMAC=""\""kong"\""   (v4.14)"
ZIGRA_FMAC=""\""zigra"\"" (v5.4 )"

while true; do
  case $LINUX_KERNEL in
    $LINUX_KERNEL_4_1_15) # for 4.1.15_2.0.0
      while true; do
        echo     "-------------------------------------------------------------"
        echo     "| Entry | "\""fmac"\"" version                                    |"
        echo     "|-------|---------------------------------------------------|"
        echo     "|  0.   | $MANDA_FMAC - Previous release               |"
        echo     "-------------------------------------------------------------"
        read -p "Select which entry? " ENTRY
        case $ENTRY in
          0) # for MANDA
            FMAC_VERSION=MANDA_FMAC_INDEX
            if [ "$BRANCH_TAG_OPTION"    = "y" ]; then
              #echo "DEBUG:: krogoth-manda_r2.0"
          		BRANCH_RELEASE_OPTION=7
          		BRANCH_RELEASE_NAME="$iMXkrogothmandaStableReleaseTag"
          		iMXYoctoRelease="$imxkrogothYocto"
          		YoctoBranch="krogoth"
          		fmacversion="$MANDA_FMAC"
            else
              #echo "DEBUG:: krogoth-manda"
          		BRANCH_RELEASE_OPTION=8
          		BRANCH_RELEASE_NAME="$iMXkrogothmandaDeveloperRelease"
          		iMXYoctoRelease="$imxkrogothYocto"
          		YoctoBranch="krogoth"
          		fmacversion="$MANDA_FMAC"
            fi

            break
            ;;
          *)
            echo -e "${RED}That is not a valid choice, try again.${NC}"
            echo $'\n'
            ;;
        esac
      done
      break
      ;;
    $LINUX_KERNEL_4_9_123) #for 4.9.123_2.3.0
        while true; do
          echo     "-------------------------------------------------------------"
          echo     "| Entry | "\""fmac"\"" version                                    |"
          echo     "|-------|---------------------------------------------------|"
          echo     "|  0.   | $MANDA_FMAC - Previous release               |"
          echo     "|  1.   | $KONG_FMAC - Previous release               |"
          echo -e  "|  2.   | $ZIGRA_FMAC - ${GRN}Coming soon...${NC}                  |"
          echo     "-------------------------------------------------------------"
          read -p "Select which entry? " ENTRY
          case $ENTRY in
            0) #for MANDA
              # rocko-mini-manda_r2.0
              FMAC_VERSION=MANDA_FMAC_INDEX
            	if [ "$BRANCH_TAG_OPTION"    = "y" ]; then
            		#echo "DEBUG:: rocko-mini-manda_r2.0"
            		BRANCH_RELEASE_OPTION=1
            		BRANCH_RELEASE_NAME="$iMXrockominimandaStableReleaseTag"
            		iMXYoctoRelease="$imxrockominiYocto"
            		YoctoBranch="rocko"
            		fmacversion="$MANDA_FMAC"

            	# rocko-mini-manda
              else
            		#echo "DEBUG:: rocko-mini-manda"
            		BRANCH_RELEASE_OPTION=2
            		BRANCH_RELEASE_NAME="$iMXrockominimandaDeveloperRelease"
            		iMXYoctoRelease="$imxrockominiYocto"
            		YoctoBranch="rocko"
            		fmacversion="$MANDA_FMAC"
              fi
              break
              ;;
            1) # for KONG
              FMAC_VERSION=KONG_FMAC_INDEX
              if [ "$BRANCH_TAG_OPTION"    = "y" ] && [ "$ENTRY" = "1" ]; then
                #echo "DEBUG:: rocko-mini-kong_r2.0"
                BRANCH_RELEASE_OPTION=3
                BRANCH_RELEASE_NAME="$iMXrockominikongStableReleaseTag"
                iMXYoctoRelease="$imxrockominiYocto"
                YoctoBranch="rocko"
                fmacversion="$KONG_FMAC"
              # rocko-mini-kong
              else
                #echo "DEBUG:: rocko-mini-kong"
                BRANCH_RELEASE_OPTION=4
                BRANCH_RELEASE_NAME="$iMXrockominikongDeveloperRelease"
                iMXYoctoRelease="$imxrockominiYocto"
                YoctoBranch="rocko"
                fmacversion="$KONG_FMAC"
              fi
              break
              ;;
            2) # for ZIGRA
              FMAC_VERSION=ZIGRA_FMAC_INDEX
              fmacVersion=ZIGRA
              echo "fmacVersion = $fmacVersion"
              exit
              break
              ;;
            *)
              echo -e "${RED}That is not a valid choice, try again.${NC}"
              echo $'\n'
              ;;
            esac
          done
        break
        ;;
      $LINUX_KERNEL_4_14_98)
        while true; do
          echo     "-------------------------------------------------------------"
          echo     "| Entry | "\""fmac"\"" version                                    |"
          echo     "|-------|---------------------------------------------------|"
          echo     "|  0.   | $MANDA_FMAC - Previous release               |"
          echo     "|  1.   | $KONG_FMAC - Previous release               |"
          echo -e  "|  2.   | $ZIGRA_FMAC - ${GRN}Coming soon...${NC}                  |"
          echo     "-------------------------------------------------------------"
          read -p "Select which entry? " FMAC_VERSION
          case $FMAC_VERSION in
            0) # for MANDA
              FMAC_VERSION=MANDA_FMAC_INDEX
              if [ "$BRANCH_TAG_OPTION"    = "y" ]; then
            		echo "DEBUG:: sumo-manda_r1.0"
            		BRANCH_RELEASE_OPTION=9
            		BRANCH_RELEASE_NAME="$iMXsumomandaStableReleaseTag"
            		iMXYoctoRelease="$imxsumoYocto"
            		YoctoBranch="sumo"
            		fmacversion="$MANDA_FMAC"
            	# sumo-manda
              else
            		echo "DEBUG:: sumo-manda"
            		BRANCH_RELEASE_OPTION=10
            		BRANCH_RELEASE_NAME="$iMXsumomandaDeveloperRelease"
            		iMXYoctoRelease="$imxsumoYocto"
            		YoctoBranch="sumo"
            		fmacversion="$MANDA_FMAC"
            	fi
              break
              ;;
            1) #for KONG
              FMAC_VERSION=KONG_FMAC_INDEX
              if [ "$BRANCH_TAG_OPTION"    = "y" ]; then
            		echo "DEBUG:: sumo-kong_r1.0"
            		BRANCH_RELEASE_OPTION=1
            		BRANCH_RELEASE_NAME="$iMXsumokongStableReleaseTag"
            		iMXYoctoRelease="$imxsumoYocto"
            		YoctoBranch="sumo"
            		fmacversion="$KONG_FMAC"
            	# sumo-kong
              else
            		echo "DEBUG:: sumo-kong"
            		BRANCH_RELEASE_OPTION=2
            		BRANCH_RELEASE_NAME="$iMXsumokongDeveloperRelease"
            		iMXYoctoRelease="$imxsumoYocto"
            		YoctoBranch="sumo"
            		fmacversion="$KONG_FMAC"
              fi
              break
              ;;
            2)
            # for ZIGRA
              FMAC_VERSION=ZIGRA_FMAC_INDEX
              fmacVersion=ZIGRA
              echo "fmacVersion = $fmacVersion"
              exit
              break
              ;;
            *)
              echo -e "${RED}That is not a valid choice, try again.${NC}"
              echo $'\n'
              ;;
            esac
          done
        break
        ;;
        $LINUX_KERNEL_5_4_24)
          while true; do
            echo     "-------------------------------------------------------------"
            echo     "| Entry | "\""fmac"\"" version                                    |"
            echo     "|-------|---------------------------------------------------|"
            echo -e  "|  0.   | $ZIGRA_FMAC - ${GRN}Coming soon...${NC}                 |"
            echo     "-------------------------------------------------------------"
            read -p "Select which entry? " FMAC_VERSION
            case $FMAC_VERSION in
              0)
              # for ZIGRA
                FMAC_VERSION=ZIGRA_FMAC_INDEX
                fmacVersion=ZIGRA
                echo "fmacVersion = $fmacVersion"
                exit
                break
                ;;
              *)
                echo -e "${RED}That is not a valid choice, try again.${NC}"
                echo $'\n'
                ;;
              esac
            done
          break
          ;;

     #*)
      #  echo -e "${RED}11That is not a valid choice, try again.${NC}"
      #  ;;
  esac
done


while true; do
  case $LINUX_KERNEL in
    $LINUX_KERNEL_4_1_15) # for 4.1.15_2.0.0
        while true; do
          echo " "
        	echo "7) Select target"
        	echo "----------------"
        	echo " "
        	echo "------------------------------------------------------"
        	echo "| Entry  |    Target Name    | i.MX Platform         |"
        	echo "|--------|-------------------|-----------------------|"
        	echo "|  1     |  imx7dsabresd     | i.MX 7Dual SDB        |"
        	echo "|  2     |  imx6qpsabresd    | i.MX 6QuadPlus SDB    |"
        	echo "|  3     |  imx6qsabresd     | i.MX 6Quad SDB        |"
        	echo "|  4     |  imx6dlsabresd    | i.MX 6DualLite SDB    |"
        	echo "|  5     |  imx6sxsabresd    | i.MX 6SX  SDB         |"
        	echo "|  6     |  imx6slevk        | i.MX 6SL  EVK         |"
        	echo "|  7     |  imx6ulevk        | i.MX 6UL  EVK         |"
        	echo "|  8     |  imx6ull14x14evk  | i.MX 6ULL EVK(14x14)  |"
        	echo "|  9     |  imx6ull9x9evk    | i.MX 6ULL EVK(9x9)    |"
        	echo "------------------------------------------------------"
        	echo -n "Select your entry: "
        	read TARGET_OPTION
        	case $TARGET_OPTION in
        		1)
        		TARGET_NAME=imx7dsabresd
        		break
        		;;

        		2)
        		TARGET_NAME=imx6qpsabresd
        		break
        		;;

        		3)
        		TARGET_NAME=imx6qsabresd
        		break
        		;;

        		4)
        		TARGET_NAME=imx6dlsabresd
        		break
        		;;

        		5)
        		TARGET_NAME=imx6sxsabresd
        		break
        		;;

        		6)
        		TARGET_NAME=imx6slevk
        		break
        		;;

        		7)
        		TARGET_NAME=imx6ulevk
        		break
        		;;

        		8)
        		TARGET_NAME=imx6ull14x14evk
        		break
        		;;

        		9)
        		TARGET_NAME=imx6ull9x9evk
        		break
        		;;

        		*)
        		echo -e "${RED}That is not a valid choice, try again.${NC}"
        		;;
        	esac
        done

        echo -e "${GRN}Selected target: $TARGET_NAME ${NC}"
        echo $'\n'
        #	Start - Prompt user to select VIO Signaling
        	if [ "$TARGET_NAME" = "imx6ulevk" ] ||  [ "$TARGET_NAME" = "imx6ull14x14evk" ] ; then
        		while true; do
        		echo " "
        		echo "7.1) Select VIO Signaling"
        		echo "-------------------------"
        		echo " "
        		echo    "------------------------------------------------------------------------------"
        		echo    "| Entry  |  Options                                                          |"
        		echo    "|--------|-------------------------------------------------------------------|"
        		echo -e "|   1.   | 1.8V VIO signaling                                                |"
        		echo -e "|   2.   | 3.3V VIO signaling                                                |"
        		echo    "------------------------------------------------------------------------------"
        		echo -e "| Note 1: Using ${YLW}V1/V2 Samtec${NC} Adapter ${YLW}HW mods reguired${NC} for ${YLW}1.8V${NC} VIO signaling |"
        		echo -e "| Note 2: Using ${GRN}uSd-M2${NC} Adapter ${GRN}disconnect J12${NC} for ${GRN}1.8V${NC} VIO signaling         |"
        		echo -e "| Note 3: Using ${GRN}uSd-M2${NC} Adapter ${GRN}connect J12${NC} for ${GRN}3.3V${NC} VIO signaling            |"
        		echo     "------------------------------------------------------------------------------"
        		echo " "
                        echo " Refer to Murata Quickstart Guide for more details:"
                        echo " - Murata Wi-Fi BT Solution for i.MX Quick Start Guide (Linux) 5.x.pdf"
        		echo " "

        		echo -n "Select your entry: "
        		read VIO_SIGNALING_OPTION
        		case $VIO_SIGNALING_OPTION in
        			1)
              BUILD_1_8V_VIO_IMAGE=1
        			LINUX_SRC=linux-imx_4.1.15.bbappend.6UL_6ULL@1.8V
        			LINUX_DEST=linux-imx_4.1.15.bbappend
        			VIO_SIGNALING_STRING="1.8V VIO signaling"
        			break
        			;;

        			2)
              BUILD_1_8V_VIO_IMAGE=0
        			LINUX_SRC=linux-imx_4.1.15.bbappend
        			LINUX_DEST=linux-imx_4.1.15.bbappend
        			VIO_SIGNALING_STRING="3.3V VIO signaling"
        			break
        			;;

        			*)
        			echo -e "${RED}That is not a valid choice, try again.${NC}"
        			;;
        		esac
        		done
        		echo -e "${GRN}Selected $VIO_SIGNALING_STRING. ${NC}"
        	fi

        	if [ "$TARGET_NAME" = "imx6sxsabresd" ]; then
        		LINUX_SRC=linux-imx_4.1.15.bbappend
        		LINUX_DEST=linux-imx_4.1.15.bbappend
        		VIO_SIGNALING_STRING="3.3V VIO signaling"
        		echo -e "${GRN}Selected $VIO_SIGNALING_STRING. ${NC}"
        	fi
        #	End - Prompt user to select VIO Signaling

        break
        ;;
      $LINUX_KERNEL_4_9_123) #for 4.9.123_2.3.0
        while true; do
          echo " "
    			echo "7) Select Target"
    			echo "----------------"
    			echo " "
    			echo "------------------------------------------------------"
    			echo "| Entry  |    Target Name    | i.MX Platform         |"
    			echo "|--------|-------------------|-----------------------|"
    			echo "|  1     |  imx7dsabresd     | i.MX 7Dual SDB        |"
    			echo "|  2     |  imx6qpsabresd    | i.MX 6QuadPlus SDB    |"
    			echo "|  3     |  imx6qsabresd     | i.MX 6Quad SDB        |"
    			echo "|  4     |  imx6dlsabresd    | i.MX 6DualLite SDB    |"
    			echo "|  5     |  imx6sxsabresd    | i.MX 6SX  SDB         |"
    			echo "|  6     |  imx6slevk        | i.MX 6SL  EVK         |"
    			echo "|  7     |  imx6ulevk        | i.MX 6UL  EVK         |"
    			echo "|  8     |  imx6ull14x14evk  | i.MX 6ULL EVK(14x14)  |"
    			echo "|  9     |  imx6ull9x9evk    | i.MX 6ULL EVK(9x9)    |"
    			echo "|  10    |  imx7ulpevk       | i.MX 7ULP EVK         |"
    			echo "|  11    |  imx8mqevk        | i.MX 8MQuad EVK       |"
    			echo "|  12    |  imx8qmmek        | i.MX 8MQuad Max EVK   |"
    			echo "|  13    |  imx8qxpmek       | i.MX 8MQuadXPlus EVK  |"
    			echo "|  14    |  imx8mmevk        | i.MX 8M Mini EVK      |"
    			echo "------------------------------------------------------"
    			echo -n "Select your entry: "
    			read TARGET_OPTION

    			case $TARGET_OPTION in
    				1)
    				TARGET_NAME=imx7dsabresd
    				break
    				;;

    				2)
    				TARGET_NAME=imx6qpsabresd
    				break
    				;;

    				3)
    				TARGET_NAME=imx6qsabresd
    				break
    				;;

    				4)
    				TARGET_NAME=imx6dlsabresd
    				break
    				;;

    				5)
    				TARGET_NAME=imx6sxsabresd
    				break
    				;;

    				6)
    				TARGET_NAME=imx6slevk
    				break
    				;;

    				7)
    				TARGET_NAME=imx6ulevk
    				break
    				;;

    				8)
    				TARGET_NAME=imx6ull14x14evk
    				break
    				;;

    				9)
    				TARGET_NAME=imx6ull9x9evk
    				break
    				;;

    				10)
    				TARGET_NAME=imx7ulpevk
    				break
    				;;

    				11)
  				  LINUX_SRC=linux-imx_4.9.123.bbappend.8MQ
  				  LINUX_DEST=linux-imx_4.9.123.bbappend
    				TARGET_NAME=imx8mqevk
            DISTRO_NAME=fsl-imx-wayland
    				break
    				;;

    				12)
    				LINUX_SRC=linux-imx_4.9.123.bbappend.8MQ
    				LINUX_DEST=linux-imx_4.9.123.bbappend
    				TARGET_NAME=imx8qmmek
            DISTRO_NAME=fsl-imx-wayland
    				break
    				;;

    				13)
    				LINUX_SRC=linux-imx_4.9.123.bbappend.8MQ
    				LINUX_DEST=linux-imx_4.9.123.bbappend
    				TARGET_NAME=imx8qxpmek
            DISTRO_NAME=fsl-imx-wayland
    				break
    				;;

    				14)
    				LINUX_SRC=linux-imx_4.9.123.bbappend.8MQ
    				LINUX_DEST=linux-imx_4.9.123.bbappend
    				TARGET_NAME=imx8mmevk
            DISTRO_NAME=fsl-imx-wayland
    				break
    				;;

    				*)
    				echo -e "${RED}That is not a valid choice, try again.${NC}"
    				;;
    		    esac
          done
          echo -e "${GRN}Selected target: $TARGET_NAME ${NC}"
        	echo $'\n'

        			#	Start - Prompt user to select VIO Signaling
        				if [ "$TARGET_NAME" = "imx6ulevk" ] ||  [ "$TARGET_NAME" = "imx6ull14x14evk" ] ||  [ "$TARGET_NAME" = "imx6ull9x9evk" ]; then
        					while true; do

        					echo " "
        					echo "7.1) Select VIO Signaling"
        					echo "-------------------------"
        					echo " "
        					echo    "------------------------------------------------------------------------------"
        					echo    "| Entry  |  Options                                                          |"
        					echo    "|--------|-------------------------------------------------------------------|"
        					echo -e "|   1.   | 1.8V VIO signaling                                                |"
        					echo -e "|   2.   | 3.3V VIO signaling                                                |"
        					echo    "------------------------------------------------------------------------------"
        					echo -e "| Note 1: Using ${YLW}V1/V2 Samtec${NC} Adapter ${YLW}HW mods reguired${NC} for ${YLW}1.8V${NC} VIO signaling |"
        					echo -e "| Note 2: Using ${GRN}uSd-M2${NC} Adapter ${GRN}disconnect J12${NC} for ${GRN}1.8V${NC} VIO signaling         |"
        					echo -e "| Note 3: Using ${GRN}uSd-M2${NC} Adapter ${GRN}connect J12${NC} for ${GRN}3.3V${NC} VIO signaling            |"
        					echo    "------------------------------------------------------------------------------"
        					echo " "
        					echo " Refer to Murata Quickstart Guide for more details:"
        					echo " - Murata Wi-Fi BT Solution for i.MX Quick Start Guide (Linux) 5.x.pdf"
        					echo " "

        					echo -n "Select your entry: "
        					read VIO_SIGNALING_OPTION
        					case $VIO_SIGNALING_OPTION in
        						1)
                    BUILD_1_8V_VIO_IMAGE=1
        						LINUX_SRC=linux-imx_4.9.123.bbappend.6UL_6ULL@1.8V
        						LINUX_DEST=linux-imx_4.9.123.bbappend
        						VIO_SIGNALING_STRING="1.8V VIO signaling"
        						break
        						;;

        						2)
                    BUILD_1_8V_VIO_IMAGE=0
        						LINUX_SRC=linux-imx_4.9.123.bbappend
        						LINUX_DEST=linux-imx_4.9.123.bbappend
        						VIO_SIGNALING_STRING="3.3V VIO signaling"
        						break
        						;;

        						*)
        						echo -e "${RED}That is not a valid choice, try again.${NC}"
        						;;
        					esac
        					done
        					echo -e "${GRN}Selected $VIO_SIGNALING_STRING. ${NC}"
        				fi

        				if [ "$TARGET_NAME" = "imx6sxsabresd" ]; then
        					LINUX_SRC=linux-imx_4.9.123.bbappend
        					LINUX_DEST=linux-imx_4.9.123.bbappend
        					#echo " "
        					echo -e "${YLW} If you are using uSD-M2 Adapter ${NC}"
        					echo -e "${YLW}  - Please plug the adapter in SD2 slot${NC}"
        					VIO_SIGNALING_STRING="3.3V VIO signaling"
        					echo -e "${GRN}Selected $VIO_SIGNALING_STRING. ${NC}"
        					#echo " "
        				fi

        				if [ "$TARGET_NAME" = "imx7ulpevk" ]; then
        					LINUX_SRC=linux-imx_4.9.123.bbappend
        					LINUX_DEST=linux-imx_4.9.123.bbappend
        					VIO_SIGNALING_STRING="3.3V VIO signaling"
        					echo -e "${GRN}Selected $VIO_SIGNALING_STRING. ${NC}"
        				fi
        			#	End - Prompt user to select VIO Signaling
        break
        ;;
      $LINUX_KERNEL_4_14_98)
        while true; do
          echo " "
          echo "7) Select Target"
          echo "----------------"
          echo " "
          echo "------------------------------------------------------"
          echo "| Entry  |    Target Name    | i.MX Platform         |"
          echo "|--------|-------------------|-----------------------|"
          echo "|  1     |  imx7dsabresd     | i.MX 7Dual SDB        |"
          echo "|  2     |  imx6qpsabresd    | i.MX 6QuadPlus SDB    |"
          echo "|  3     |  imx6qsabresd     | i.MX 6Quad SDB        |"
          echo "|  4     |  imx6dlsabresd    | i.MX 6DualLite SDB    |"
          echo "|  5     |  imx6sxsabresd    | i.MX 6SX  SDB         |"
          echo "|  6     |  imx6slevk        | i.MX 6SL  EVK         |"
          echo "|  7     |  imx6ulevk        | i.MX 6UL  EVK         |"
          echo "|  8     |  imx6ull14x14evk  | i.MX 6ULL EVK(14x14)  |"
          echo "|  9     |  imx6ull9x9evk    | i.MX 6ULL EVK(9x9)    |"
          echo "|  10    |  imx7ulpevk       | i.MX 7ULP EVK         |"
          echo "|  11    |  imx8mqevk        | i.MX 8MQuad EVK       |"
          echo "|  12    |  imx8qmmek        | i.MX 8MQuad Max  EVK  |"
          echo "|  13    |  imx8qxpmek       | i.MX 8MQuadXPlus EVK  |"
          echo "|  14    |  imx8mmevk        | i.MX 8M Mini EVK      |"
          echo "|  15    |  imx8mmddr4evk    | i.MX 8M Mini DDR4 EVK |"
          echo "|  16    |  imx8mnevk        | i.MX 8M Nano EVK      |"
          echo "------------------------------------------------------"
          echo -n "Select your entry: "
          read TARGET_OPTION
          case $TARGET_OPTION in
            1)
            TARGET_NAME=imx7dsabresd
            break
            ;;

            2)
            TARGET_NAME=imx6qpsabresd
            break
            ;;

            3)
            TARGET_NAME=imx6qsabresd
            break
            ;;

            4)
            TARGET_NAME=imx6dlsabresd
            break
            ;;

            5)
            TARGET_NAME=imx6sxsabresd
            break
            ;;

            6)
            TARGET_NAME=imx6slevk
            break
            ;;

            7)
            TARGET_NAME=imx6ulevk
            break
            ;;

            8)
            TARGET_NAME=imx6ull14x14evk
            break
            ;;

            9)
            TARGET_NAME=imx6ull9x9evk
            break
            ;;

            10)
            TARGET_NAME=imx7ulpevk
            break
            ;;

            11)
            TARGET_NAME=imx8mqevk
            LINUX_SRC=linux-imx_4.14.98.bbappend.8MQ
            LINUX_DEST=linux-imx_4.14.98.bbappend
            DISTRO_NAME=fsl-imx-wayland
            break
            ;;

            12)
            TARGET_NAME=imx8qmmek
            LINUX_SRC=linux-imx_4.14.98.bbappend.8MQ
            LINUX_DEST=linux-imx_4.14.98.bbappend
            DISTRO_NAME=fsl-imx-wayland
            break
            ;;

            13)
            TARGET_NAME=imx8qxpmek
            LINUX_SRC=linux-imx_4.14.98.bbappend.8MQ
            LINUX_DEST=linux-imx_4.14.98.bbappend
            DISTRO_NAME=fsl-imx-wayland
            break
            ;;

            14)
            TARGET_NAME=imx8mmevk
            LINUX_SRC=linux-imx_4.14.98.bbappend.8MQ
            LINUX_DEST=linux-imx_4.14.98.bbappend
            DISTRO_NAME=fsl-imx-wayland
            break
            ;;

            15)
            TARGET_NAME=imx8mmddr4evk
            LINUX_SRC=linux-imx_4.14.98.bbappend.8MQ
            LINUX_DEST=linux-imx_4.14.98.bbappend
            DISTRO_NAME=fsl-imx-wayland
            break
            ;;

            16)
            TARGET_NAME=imx8mnevk
            LINUX_SRC=linux-imx_4.14.98.bbappend.8MQ
            LINUX_DEST=linux-imx_4.14.98.bbappend
            DISTRO_NAME=fsl-imx-wayland
            break
            ;;

            *)
            echo -e "${RED}That is not a valid choice, try again.${NC}"
            ;;
          esac
        done
        echo -e "${GRN}Selected target: $TARGET_NAME ${NC}"
        echo $'\n'

        	#	Start - Prompt user to select VIO Signaling
        		if [ "$TARGET_NAME" = "imx6ulevk" ] ||  [ "$TARGET_NAME" = "imx6ull14x14evk" ] ||  [ "$TARGET_NAME" = "imx6ull9x9evk" ]; then
        			while true; do

        			echo " "
        			echo "7.1) Select VIO Signaling"
        			echo "-------------------------"
        			echo " "
        			echo    "------------------------------------------------------------------------------"
        			echo    "| Entry  |  Options                                                          |"
        			echo    "|--------|-------------------------------------------------------------------|"
        			echo -e "|   1.   | 1.8V VIO signaling                                                |"
        			echo -e "|   2.   | 3.3V VIO signaling                                                |"
        			echo    "------------------------------------------------------------------------------"
        			echo -e "| Note 1: Using ${YLW}V1/V2 Samtec${NC} Adapter ${YLW}HW mods reguired${NC} for ${YLW}1.8V${NC} VIO signaling |"
        			echo -e "| Note 2: Using ${GRN}uSd-M2${NC} Adapter ${GRN}disconnect J12${NC} for ${GRN}1.8V${NC} VIO signaling         |"
        			echo -e "| Note 3: Using ${GRN}uSd-M2${NC} Adapter ${GRN}connect J12${NC} for ${GRN}3.3V${NC} VIO signaling            |"
        			echo    "------------------------------------------------------------------------------"
        			echo " "
        			echo " Refer to Murata Quickstart Guide for more details:"
        			echo " - Murata Wi-Fi BT Solution for i.MX Quick Start Guide (Linux) 5.x.pdf"
        			echo " "

        			echo -n "Select your entry: "
        			read VIO_SIGNALING_OPTION
        			case $VIO_SIGNALING_OPTION in
        				1)
                  BUILD_1_8V_VIO_IMAGE=1
                  LINUX_SRC=linux-imx_4.14.98.bbappend.6UL_6ULL@1.8V
          				LINUX_DEST=linux-imx_4.14.98.bbappend
          				VIO_SIGNALING_STRING="1.8V VIO signaling"
        				  break
        				  ;;

        				2)
                  BUILD_1_8V_VIO_IMAGE=0
                  LINUX_SRC=linux-imx_4.14.98.bbappend
          				LINUX_DEST=linux-imx_4.14.98.bbappend
          				VIO_SIGNALING_STRING="3.3V VIO signaling"
        				  break
        				  ;;

        				*)
        				  echo -e "${RED}That is not a valid choice, try again.${NC}"
        					;;
        			esac
        			done
        			echo -e "${GRN}Selected $VIO_SIGNALING_STRING. ${NC}"
        		fi

        		if [ "$TARGET_NAME" = "imx7ulpevk" ]; then
        			LINUX_SRC=linux-imx_4.14.98.bbappend
        			LINUX_DEST=linux-imx_4.14.98.bbappend
        			VIO_SIGNALING_STRING="3.3V VIO signaling"
        			echo -e "${GRN}Selected $VIO_SIGNALING_STRING. ${NC}"
        		fi

          #	End - Prompt user to select VIO Signaling
        break
        ;;
     *)
        echo -e "${RED}That is not a valid choice, try again.${NC}"
        ;;
  esac
done


echo " "
echo "8) Select DISTRO & Image"
echo "------------------------"
echo " "
echo "Murata default DISTRO & Image pre-selected are:"
echo -e "${GRN}DISTRO: $DISTRO_NAME${NC}"
echo -e "${GRN}Image:  $IMAGE_NAME${NC}"
echo " "
echo -e -n "Proceed with this configuration? ${GRN}Y${NC}/${YLW}n${NC}: "
read PROMPT

if [ "$PROMPT" = "n" ] || [ "$PROMPT" = "N" ]; then
	echo -e "${YLW}Select unsupported options (for DISTRO and Image) by entering: "\""U"\"" at the next prompt."
	echo " "
	echo -e -n "Do you REALLY want to proceed ?: U${NC}: "
	read PROMPT


   	  	if [ "$PROMPT" = "U" ] || [ "$PROMPT" = "u" ]; then
			echo " "
			echo "7.1) Select DISTRO"
			echo "------------------"
			echo " "
			echo "----------------------------------------------------------------------------"
			echo "| Entry |   DISTRO Name     |    Description                               |"
			echo "|-------|-------------------|----------------------------------------------|"
			echo "|   1   | fsl-imx-x11       | Only X11 graphics                            |"
			echo "|   2   | fsl-imx-wayland   | Wayland weston graphics                      |"
			echo "|   3   | fsl-imx-xwayland  | Wayland graphics and X11. X11 applications   |"
			echo "|       |                   | using EGL are not supported                  |"
			echo "|   4   | fsl-imx-fb        | Frame Buffer graphics - no X11 or Wayland    |"
			echo "----------------------------------------------------------------------------"

			#       Prompting the user to select the DISTRO
			echo " "
			while true; do
				echo -e -n "Select your entry for DISTRO: "
				read DISTRO_OPTION
				case $DISTRO_OPTION in
					1)
					DISTRO_NAME=fsl-imx-x11
					break
					;;

					2)
					DISTRO_NAME=fsl-imx-wayland
					break
					;;

					3)
					DISTRO_NAME=fsl-imx-xwayland
					break
					;;

					4)
					DISTRO_NAME=fsl-imx-fb
					break
					;;

					*)
					echo -e "${RED}That is not a valid choice, try again.${NC}"
					;;
				esac
			done
			echo -e "${GRN}Selected DISTRO: $DISTRO_NAME. ${NC}"
		else
			echo -e "${GRN}Proceeding with Murata default DISTRO: $DISTRO_NAME${NC}"
		fi

	#       Prompting the user to select which image to build
	  	if [ "$PROMPT" = "U" ] || [ "$PROMPT" = "u" ]; then

			echo ""
			echo " "
			echo "7.2) Select Image"
			echo "-----------------"
			echo " "

			#echo "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
			echo "--------------------------------------------------------------------------------"
			echo "| Entry |      Image Name              | Description                           |"
			echo "|-------|------------------------------|---------------------------------------|"
			echo "|   1   | core-image-sato              | An image with Sato, a mobile          |"
			echo "|       |                              | environment and visual style for      |"
			echo "|       |                              | mobile devices. The image supports X11|"
			echo "|       |                              | with a Sato theme and uses Pimlico    |"
			echo "|       |                              | applications. It contains a terminal, |"
			echo "|       |                              | an editor and a file manager.         |"
			echo "|       |                              |                                       |"
			echo "|   2   | fsl-image-machine-test       | An FSL Community i.MX core image with |"
			echo "|       |                              | console environment - no GUI interface|"
			echo "|       |                              |                                       |"
			echo "|   3   | fsl-image-validation-imx     | Builds an i.MX image with a GUI       |"
		     echo -e "|       | ${GRN}(tested)${NC}                     | without any Qt content.               |"
			echo "|       |                              |                                       |"
			echo "|       |                              |                                       |"
			echo "|   4   | fsl-image-qt5-validation-imx | Builds an opensource Qt 5 image. These|"
			echo "|       |                              | images are only supported for i.MX SoC|"
			echo "|       |                              | with hardware graphics. They are not  |"
			echo "|       |                              | supported on the i.MX 6UltraLite,     |"
			echo "|       |                              | i.MX 6UltraLiteLite, and i.MX 7Dual.  |"
			echo "|       |                              |                                       |"
			echo "|   5   | core-image-base              | A console-only image that fully       |"
		     echo -e "|       | ${GRN}(tested)${NC}                     | supports the target device hardware.  |"
		     	echo "|       |                              |                                       |"
			echo "--------------------------------------------------------------------------------"

			while true; do
			echo -e -n "Select your entry: "
			read IMAGE_OPTION
			case $IMAGE_OPTION in
				1)
				IMAGE_NAME=core-image-sato
				break
				;;

				2)
				IMAGE_NAME=fsl-image-machine-test
				break
				;;

				3)
				IMAGE_NAME=fsl-image-validation-imx
				break
				;;

				4)
				IMAGE_NAME=fsl-image-qt5-validation-imx
				break
				;;

				5)
				IMAGE_NAME=core-image-base
				break
				;;

				*)
				echo -e "${RED}That is not a valid choice, try again.${NC}"
				;;
			esac
			done
			echo -e "${GRN}Selected Image: $IMAGE_NAME. ${NC}"
		else
			echo -e "${GRN}Proceeding with Murata default Image:  $IMAGE_NAME${NC}"
		fi

else
	echo -e "${GRN}Proceeding with Murata defaults.${NC}"
fi


#echo $'\n'
#echo "-------------------------------Creation of Build Directory---------------------------"
echo " "
echo "9) Creation of Build directory"
echo "------------------------------"
echo " "
echo "Ex: <build-imx6ulevk-x11> for imx6ulevk with x11 backend"
echo "Ex: <build-xwayland-imx8mq> for imx8mqevk with xwayland backend"
echo " "
echo "NOTE: The directory will be created in your <fsl-yocto-bsp-release> folder."
while true; do

export CWD=`pwd`
#echo "DEBUG:: :Current working directory :: $CWD"
echo " "
echo -n "Enter build directory name: "
read BUILD_DIR_NAME

#To check if a directory exists
	if [ "$BUILD_DIR_NAME" = "" ]; then
 		echo -e "Provide a valid build directory${RED}.....FAIL${NC}"
	elif [ -d "$BUILD_DIR_NAME" ]; then
		echo -e "${RED}Error: Conflict with existing build directory - $BUILD_DIR_NAME.${NC}"
		echo " "
		echo "You have 2 options:"
		echo "1. You can provide another build directory name. "
		echo "2. If this is a continuation of a build that was aborted, then"
		echo "   (a) Execute the following command from BSP directory:"
		echo "       $ source setup-environment $BUILD_DIR_NAME"
		echo "   (b) Execute the following command from $BUILD_DIR_NAME directory:"
		echo "       $ bitbake fsl-imaga-validation-imx"
		echo " "
		read -p "Select which entry 1 or 2? " DIR_OPTION
		if [ "$DIR_OPTION" = "2" ]; then
			echo "${RED}Build script has been termintated.${NC}"
			exit
		fi
	else
		#echo "DEBUG:: NEW DIRECTORY: $BUILD_DIR_NAME"
		break
	fi
done

echo " "
echo "10) Verify your selection"
echo "-------------------------"
echo " "

echo -e "i.MX Yocto Release              : ${GRN}$iMXYoctoRelease${NC}"
echo -e "Yocto branch                    : ${GRN}$YoctoBranch${NC}"
echo -e "fmac version                    : ${GRN}$fmacversion${NC}"
echo -e "Target                          : ${GRN}$TARGET_NAME${NC}"
echo -e "meta-murata-wireless Release Tag: ${GRN}$BRANCH_RELEASE_NAME${NC}"


# if the selected branch is i.MX8, then don't display the VIO Signaling selection
if [ "$BRANCH_RELEASE_OPTION" -ne "1" ] && [ "$BRANCH_RELEASE_OPTION" -ne "4" ]; then
#	echo    "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
	echo -e "VIO Signaling                   : ${GRN}$VIO_SIGNALING_STRING${NC}"
fi

#BRANCH=morty-manda
if [ "$FMAC_VERSION" = $MANDA_FMAC_INDEX ]; then
	if [ $BRANCH_RELEASE_OPTION = "3" ] || [ $BRANCH_RELEASE_OPTION = "4" ]; then
		#echo "DEBUG FOR MORTY-MANDA-1:: IMX6 and 7"
		echo -e "VIO Signaling                   : ${GRN}$VIO_SIGNALING_STRING${NC}"
	fi
fi

echo -e "DISTRO                          : ${GRN}$DISTRO_NAME${NC}"
echo -e "Image                           : ${GRN}$IMAGE_NAME ${NC}"
echo -e "Build Directory                 : ${GRN}$BUILD_DIR_NAME${NC}"


echo " "
echo "Please verify your selection"


echo -e -n "Do you accept selected configurations ? ${GRN}Y${NC}/${YLW}n${NC}: "
read REPLY

if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ] || [ "$REPLY" = "" ]; then
	echo " "
	echo "11) Acceptance of End User License Agreement(EULA)"
	echo "--------------------------------------------------"
	echo " "
       #echo "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
	echo "********************************************************************************"
	echo "* Thank you for entering necessary configuration!                             *"
	echo "* Please be patient to complete the last phase of the build script process.    *"
	echo "* Final steps of the build script require user to review and accept            *"
	echo "* NXP/Freescale Software License Agreement.                                    *"
	echo "*                                                                              *"
	echo -e "* ${YLW}NOTE: It may take several minutes to display EULA Agreement.                 ${NC}*"
	echo "*                                                                              *"
	echo -e "* User is prompted to enter space bar to fully display EULA Agreement OR "\'"q"\'"   *"
	echo "* to quit reading entire EULA.                                                 *"
	echo "*                                                                              *"
	echo "* Please enter space bar (repeatedly)  OR 'q' until you see the final EULA     *"
        echo "* acceptance prompt as shown below:                                            *"
	echo "*                                                                              *"
        echo -e "* ${GRN}Do you accept the EULA you just read? (y/n)                                  ${NC}*"
	echo "*                                                                              *"
	echo "* Please make sure to enter 'y', so build script continues.                    *"
	echo "* Once EULA has been successfully accepted following line is displayed:        *"
	echo "*                                                                              *"
	echo -e "* ${GRN}EULA has been accepted.${NC}                                                      *"
	echo "*                                                                              *"
	echo "* Once EULA is accepted, final step (last User Prompt) is to kick off Yocto    *"
        echo "* build.                                                                       *"
	echo "********************************************************************************"
	echo " "


	while true; do
	echo -e -n "Do you want to continue? ${GRN}Y${NC}/${YLW}n${NC}: "
	read PROCEED_OPTION

	if [ "$PROCEED_OPTION" = "Y" ] || [ "$PROCEED_OPTION" = "y" ] || [ "$PROCEED_OPTION" = "" ]; then
		break
	elif [ "$PROCEED_OPTION" = "n" ] || [ "$PROCEED_OPTION" = "N" ]; then
		echo -e "${RED}Exiting script.....${NC}"
		exit
	else
		echo -e "${RED}That is not a valid choice, try again.${NC}"
	fi
	done

	# Invoke Repo Init based on Yocto Release
  if [ "$iMXYoctoRelease" = "$imxsumoYocto" ]; then
		#echo "DEBUG:: IMXALL-SUMO"
		repo init -u https://source.codeaurora.org/external/imx/imx-manifest -b imx-linux-sumo -m imx-4.14.98-2.3.0.xml
	elif [ "$iMXYoctoRelease" = "$imxrockominiYocto" ]; then
		#echo "DEBUG:: IMXALL-ROCKO-MINI"
		repo init -u https://source.codeaurora.org/external/imx/imx-manifest -b imx-linux-rocko -m imx-4.9.123-2.3.0-8mm_ga.xml
	elif [ "$iMXYoctoRelease" = "$imxkrogothYocto"  ]; then
		#echo "DEBUG:: KROGOTH"
		repo init -u https://source.codeaurora.org/external/imx/fsl-arm-yocto-bsp.git -b imx-4.1-krogoth -m imx-4.1.15-2.0.0.xml
	fi

	#echo "DEBUG:: Performing repo sync......."
	repo sync
	cd $BSP_DIR


	#echo "DEBUG:: Performing Setup of DISTRO and MACHINE"
	#echo "DEBUG:: pwd = $BSP_DIR"
  DISTRO=$DISTRO_NAME MACHINE=$TARGET_NAME source ./fsl-setup-release.sh -b $BUILD_DIR_NAME
  export BUILD_DIR=`pwd`

	cd $BSP_DIR/sources
	git clone $META_MURATA_WIRELESS_GIT
	cd meta-murata-wireless

	git checkout $BRANCH_RELEASE_NAME
	cd $BSP_DIR
  if [ "$BUILD_1_8V_VIO_IMAGE" == "1" ]; then
    echo "Build 1.8V Image"
  	chmod 777 sources/meta-murata-wireless/add-murata-layer-script/add-murata-wireless_1.8v.sh
  	sh ./sources/meta-murata-wireless/add-murata-layer-script/add-murata-wireless_1.8v.sh $BUILD_DIR_NAME
  else
    echo "Build 3.3V Image"
  	chmod 777 sources/meta-murata-wireless/add-murata-layer-script/add-murata-wireless.sh
  	sh ./sources/meta-murata-wireless/add-murata-layer-script/add-murata-wireless.sh $BUILD_DIR_NAME
  fi
	cd $BSP_DIR/sources/meta-murata-wireless/recipes-kernel/linux

		# MANDA is supported for ROCKO-MINI, ROCKO, MORTY and KROGOTH.

		# For TARGET_NAME = imx6ulevk, imx6ull14x14evk, imx6ull9x9evk,and imx6sxsabresd, they can have 1.8V, need to update bbappend accordingly
    if [ "$FMAC_VERSION" = $MANDA_FMAC_INDEX ] ; then
      	if [ "$TARGET_NAME" = "imx6ulevk" ] ||  [ "$TARGET_NAME" = "imx6ull14x14evk" ] ||  [ "$TARGET_NAME" = "imx6ull9x9evk" ] ||  [ "$TARGET_NAME" = "imx6sxsabresd" ]; then
    			if [ "$LINUX_SRC" != "$LINUX_DEST" ]; then
      				cp $LINUX_SRC $LINUX_DEST
    			fi
    		fi
    fi

		#TARGET_NAME=imx8mqevk => rocko-manda
		if [ "$FMAC_VERSION" = $MANDA_FMAC_INDEX ] && [ "$iMXYoctoRelease" = "$imxrockoYocto" ]; then
			#echo "DEBUG:: MANDA-LOADING-FOR-ROCKO"
			if [ "$TARGET_NAME" = "imx8mqevk" ]; then
				#echo "DEBUG:: FOR IMX8-rocko: COPYING IMX8 BACKPORTS, Murata-Binaries and bbx files"
				if [ "$LINUX_SRC" != "$LINUX_DEST" ]; then
					cp $LINUX_SRC $LINUX_DEST
				fi
				mv $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qcacld_2.0.bb \
					$BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qcacld_2.0.bbx
				mv $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qcacld-lea_1.0.bb \
					$BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qcacld-lea_1.0.bbx
				cp -f $BSP_DIR/sources/meta-murata-wireless/freescale/backporttool-linux_1.0.bb@imx8 \
					$BSP_DIR/sources/meta-murata-wireless/recipes-kernel/backporttool-linux/backporttool-linux_1.0.bb
				cp -f $BSP_DIR/sources/meta-murata-wireless/freescale/murata-binaries_1.0.bb@imx8 \
					$BSP_DIR/sources/meta-murata-wireless/recipes-connectivity/murata-binaries/murata-binaries_1.0.bb
			elif [ "$FMAC_VERSION" = $MANDA_FMAC_INDEX ] && [ "$TARGET_NAME" != "imx8mqevk" ]; then
				#echo "DEBUG:: FOR IMX6,7-rocko: COPYING bb appends files"
				if [ "$LINUX_SRC" != "$LINUX_DEST" ]; then
					cp $LINUX_SRC $LINUX_DEST
				fi
			fi

			#BRANCH=morty-manda
			if [ $BRANCH_RELEASE_OPTION = "3" ] || [ $BRANCH_RELEASE_OPTION = "4" ] || [ $BRANCH_RELEASE_OPTION = "5" ] || [ $BRANCH_RELEASE_OPTION = "6" ]; then
				#echo "DEBUG:: FOR MORTY/KROGOTH-MANDA:: IMX6 and 7: COPYING bb appends"
				if [ "$LINUX_SRC" != "$LINUX_DEST" ]; then
					cp $LINUX_SRC $LINUX_DEST
				fi
			fi
		fi

		#TARGET_NAME=imx8mqevk => rocko-mini-manda
		#if [ "$FMAC_VERSION" = $MANDA_FMAC_INDEX ] && [ "$iMXYoctoRelease" = "$imxrockominiYocto" ]; then
		if [ "$iMXYoctoRelease" = "$imxrockominiYocto" ]; then
			if [ "$FMAC_VERSION" = "$MANDA_FMAC_INDEX" ] || [ "$FMAC_VERSION" = "$KONG_FMAC_INDEX" ]; then
				#echo "DEBUG:: MANDA-LOADING-FOR-ROCKO-MINI"
				if [ "$TARGET_NAME" = "imx8mqevk" ] || [ "$TARGET_NAME" = "imx8qmmek" ] || [ "$TARGET_NAME" = "imx8mqevk" ] || [ "$TARGET_NAME" = "imx8mmevk" ]; then
					#echo "DEBUG FOR IMX8-rocko-mini: COPYING IMX8 BACKPORTS, Murata-Binaries and bbx files"
					#echo "DEBUG:: SRC::$LINUX_SRC DEST::$LINUX_SRC"
					if [ "$LINUX_SRC" != "$LINUX_DEST" ]; then
						#echo "DEBUG:: Before copying SRC::$LINUX_SRC DEST::$LINUX_DEST"
						cp $LINUX_SRC $LINUX_DEST
						#echo "DEBUG:: After copying SRC::$LINUX_SRC DEST::$LINUX_DEST"
					fi
					mv $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qca6174_2.0.bb \
						$BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qca6174_2.0.bbx
					mv $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qca9377_2.0.bb \
						$BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qca9377_2.0.bbx
					cp -f $BSP_DIR/sources/meta-murata-wireless/freescale/backporttool-linux_1.0.bb@imx8 \
						$BSP_DIR/sources/meta-murata-wireless/recipes-kernel/backporttool-linux/backporttool-linux_1.0.bb
					cp -f $BSP_DIR/sources/meta-murata-wireless/freescale/murata-binaries_1.0.bb@imx8 \
						$BSP_DIR/sources/meta-murata-wireless/recipes-connectivity/murata-binaries/murata-binaries_1.0.bb
				else
					#echo "DEBUG FOR IMX6,7-rocko-mini: COPYING bb appends files"
					if [ "$LINUX_SRC" != "$LINUX_DEST" ]; then
						cp $LINUX_SRC $LINUX_DEST
					fi
				fi
			fi
		fi

    #for sumo-manda
	if [ "$FMAC_VERSION" = $MANDA_FMAC_INDEX ] && [ "$iMXYoctoRelease" = "$imxsumoYocto" ]; then
		mv $BSP_DIR/sources/meta-openembedded/meta-oe/recipes-connectivity/hostapd/hostapd_2.6.bb $BSP_DIR/sources/meta-openembedded/meta-oe/recipes-connectivity/hostapd/hostapd_2.6.bbx
  		mv $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-connectivity/hostapd/hostapd_%.bbappend $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-connectivity/hostapd/hostapd_%.bbappendx
      		mv $BSP_DIR/sources/poky/meta/recipes-connectivity/wpa-supplicant/wpa-supplicant_2.6.bb $BSP_DIR/sources/poky/meta/recipes-connectivity/wpa-supplicant/wpa-supplicant_2.6.bbx
      		mv $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-connectivity/wpa-supplicant/wpa-supplicant_%.bbappend $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-connectivity/wpa-supplicant/wpa-supplicant_%.bbappendx

      	if [ "$LINUX_SRC" != "$LINUX_DEST" ]; then
      		#echo "DEBUG:: Before copying SRC::$LINUX_SRC DEST::$LINUX_DEST"
       		cp $LINUX_SRC $LINUX_DEST
        	#echo "DEBUG:: After copying SRC::$LINUX_SRC DEST::$LINUX_DEST"
      	fi

      	if [ "$TARGET_NAME" = "imx8mqevk" ] || [ "$TARGET_NAME" = "imx8qmmek" ] || [ "$TARGET_NAME" = "imx8mqevk" ] || [ "$TARGET_NAME" = "imx8mmevk" ]; then
        	mv $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qca6174_2.1.bb \
		        $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qca6174_2.1.bbx
		      mv $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qca9377_2.1.bb \
		        $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qca9377_2.1.bbx
        	cp -f $BSP_DIR/sources/meta-murata-wireless/freescale/murata-binaries_1.0.bb@imx8 \
		        $BSP_DIR/sources/meta-murata-wireless/recipes-connectivity/murata-binaries/murata-binaries_1.0.bb
      	fi


    fi

    #for sumo-kong
	if [ "$FMAC_VERSION" = $KONG_FMAC_INDEX ] && [ "$iMXYoctoRelease" = "$imxsumoYocto" ]; then
		mv $BSP_DIR/sources/meta-openembedded/meta-oe/recipes-connectivity/hostapd/hostapd_2.6.bb $BSP_DIR/sources/meta-openembedded/meta-oe/recipes-connectivity/hostapd/hostapd_2.6.bbx
  		mv $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-connectivity/hostapd/hostapd_%.bbappend $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-connectivity/hostapd/hostapd_%.bbappendx
      		mv $BSP_DIR/sources/poky/meta/recipes-connectivity/wpa-supplicant/wpa-supplicant_2.6.bb $BSP_DIR/sources/poky/meta/recipes-connectivity/wpa-supplicant/wpa-supplicant_2.6.bbx
      		mv $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-connectivity/wpa-supplicant/wpa-supplicant_%.bbappend $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-connectivity/wpa-supplicant/wpa-supplicant_%.bbappendx

        	if [ "$LINUX_SRC" != "$LINUX_DEST" ]; then
        		#echo "DEBUG:: Before copying SRC::$LINUX_SRC DEST::$LINUX_DEST"
         		cp $LINUX_SRC $LINUX_DEST
          	#echo "DEBUG:: After copying SRC::$LINUX_SRC DEST::$LINUX_DEST"
        	fi

        	if [ "$TARGET_NAME" = "imx8mqevk" ] || [ "$TARGET_NAME" = "imx8qmmek" ] || [ "$TARGET_NAME" = "imx8mqevk" ] || [ "$TARGET_NAME" = "imx8mmevk" ] || [ "$TARGET_NAME" = "imx8mmddr4evk" ]; then
          	mv $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qca6174_2.1.bb \
        		   $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qca6174_2.1.bbx
        		mv $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qca9377_2.1.bb \
        		   $BSP_DIR/sources/meta-fsl-bsp-release/imx/meta-bsp/recipes-kernel/kernel-modules/kernel-module-qca9377_2.1.bbx
            cp -f $BSP_DIR/sources/meta-murata-wireless/freescale/murata-binaries_1.0.bb@imx8 \
        		   $BSP_DIR/sources/meta-murata-wireless/recipes-connectivity/murata-binaries/murata-binaries_1.0.bb
      	 fi
  fi

  cd $BUILD_DIR

	echo " "
	echo "12) Starting Build Now."
	echo "-----------------------"
	echo " "
	echo -e "${YLW}NOTE: depending on machine type, build may take 1-7 hours to complete.${NC}"
	echo " "
        echo ""\'"Y"\'" to continue, "\'"n"\'" aborts build."
	echo -e -n "Do you want to start the build ? ${GRN}Y${NC}/${YLW}n${NC}: "
	read PROCEED_BUILD

	if [ "$PROCEED_BUILD" = "y" ] || [ "$PROCEED_BUILD" = "Y" ] || [ "$PROCEED_BUILD" = "" ] ; then
		bitbake $IMAGE_NAME
		exit
	else
		echo -e "${RED}Exiting script.....${NC}"
		exit
	fi
else
	echo -e "${RED}Exiting script.....${NC}"
	exit
fi

fi
#*************************************** For i.MX - end *****************************************
