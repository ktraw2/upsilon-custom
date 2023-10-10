#!/bin/bash -e
if [ -n "$JAVA8_HOME" ]; then
	export JAVA_HOME=$JAVA8_HOME
fi
v=$(env -u_JAVA_OPTIONS $JAVA_HOME/bin/java -Xint -version 2>&1 | head -n1 |cut -d\" -f2)
if [[ ! "$v" =~ ^1\.8\. ]]; then
	echo "Found Java $v - Rewind Upsilon requires Java 8. Please install it and set JAVA8_HOME to a path to it." 1>&2
	exit 1
fi
if ! grep '^flavor=' unsup.ini >/dev/null; then
	echo 'This seems to be your first time running the Rewind Upsilon server.'
	echo 'Please pick your desired configuration. Simply press Enter to accept the capitalized default:'
	function yesno() {
		while true; do
			read -p " $1? [Y/n] " RESPONSE
			case $RESPONSE in
				''|Y|y) echo 'on' ;;
				N|n) echo 'off' ;;
				*) echo 'Invalid choice'; continue ;;
			esac
			break
		done
	}
	while true; do
		read -p ' Flavor? [STANDARD/compatible/skyblock] ' FLAVOR
		case $FLAVOR in
			''|STANDARD|Standard|standard) FLAVOR=standard ;;
			COMPATIBLE|Compatible|compatible) FLAVOR=compatible ;;
			SKYBLOCK|Skyblock|skyblock) FLAVOR=skyblock ;;
			*) echo 'Invalid choice'; continue ;;
		esac
		break
	done
	GREGTECH=$(yesno GregTech)
	DARTCRAFT=$(yesno DartCraft)
	echo >> unsup.ini
	echo '[flavors]' >> unsup.ini
	echo "flavor=$FLAVOR" >> unsup.ini
	echo "gregtech=gregtech_$GREGTECH" >> unsup.ini
	echo "dartcraft=dartcraft_$DARTCRAFT" >> unsup.ini
	echo 'Your selections have been saved to unsup.ini.'
fi
# unsup has to be run separately to grab forge/mc/nilloader
$JAVA_HOME/bin/java -jar unsup.jar server
$JAVA_HOME/bin/java -Dnil.alwaysUseAdHocLogger=true -Xmn128M -Xms4G -Xmx4G -javaagent:nilloader.jar -cp forge.jar:minecraft-server.jar net.minecraft.server.MinecraftServer nogui
