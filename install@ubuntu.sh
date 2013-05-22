#!/bin/bash
# 
# The script is used to install mutt and the required packages 
# without user interaction in Ubuntu distribution
# 
# For other distribution, you can install them manually based on 
# the required package in the array `package`.
# 
# For more information, visit https://github.com/copico/.cfg/tree/master/mail
# or contact heconghui@gmail.com

INSTALL_CMD="apt-get install -y "
LOG_FILE="/tmp/mail_install_ubuntu.log"

package[0]='mutt'
package[1]='mutt-patched'
package[2]='offlineimap'
package[3]='msmtp'
package[4]='msmtp-gnome'
package[5]='notmuch'
package[6]='sqlite3'
package[7]='openssl'
package[8]='ca-certificates'
package[9]='vim'
package[10]='abook'
package[11]='elinks'
package[12]='eog'
package[13]='evince'
package[14]='urlview'
package[15]='pandoc'

# make sure only root can run this script
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

echo "The detail of installation process is in $LOG_FILE"
SIZE=`echo "${#package[@]}"`
COUNTER=1
FORMAT="%-60s"
for p in "${package[@]}"; do
  printf "${FORMAT}" "[${COUNTER}/${SIZE}] Installing ${p}" 

  # the actual install command
  $INSTALL_CMD $p &> $LOG_FILE

  # test whether installed correctly
  if [ $? -eq 0 ]; then
    echo "finished." 
  else
    echo
    echo "ERROR: Installation of ${p} failed. '$INSTALL_CMD $p'" 1>&2
    echo "ERROR: Please check the name of the package"
    echo 
    exit 1
  fi

  (( COUNTER = COUNTER + 1 ))
done

printf "${FORMAT}" "Linking the symbolic links"

ln -sf ~/.cfg/mail/offlineimap/offlineimaprc ~/.offlineimaprc && \
ln -sf ~/.cfg/mail/msmtp/msmtprc ~/.msmtprc && \
rm ~/.mutt &&  ln -sf ~/.cfg/mail/mutt ~/.mutt && \
ln -sf ~/.cfg/mail/notmuch/notmuch-config ~/.notmuch-config

printf "finished\n"

echo 
echo "!!! Please make sure ~/.cfg/mail/bin is in your PATH"
echo "!!! Plase go to ~/.cfg/mail/msmtp/        to set up smtp       keying"
echo "!!! Plase go to ~/.cfg/mail/offlineimap/  to set up offlinemap keying"
echo ""
echo "For more information, checkout README.mkd or visit"
echo "https://github.com/copico/.cfg/tree/master/mail"
