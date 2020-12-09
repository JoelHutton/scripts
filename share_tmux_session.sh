#!/bin/bash
# Share current tmux session with a guest
# Dependencies: tmux, xsel, ssh
#
# usage: share_tmux_session.sh [command]
#        commands: share   share current tmux session
#                  unshare (default) unshare current tmux session
#
# You must first create a guest user account then put the following in your
# /etc/ssh/sshd_config:
# Match User guest
#    ForceCommand /tmp/guest_login_command.sh
# then restart the ssh daemon using:
# "sudo service ssh restart"

GUEST_USER=guest
SOCKET=`echo $TMUX | cut -f1 -d','`
GUEST_SOCKET="/tmp/guest_tmux"
SESSION=`echo $TMUX | cut -f3 -d','`
SOCKET_DIR=`dirname $SOCKET`
GUEST_LOGIN_FILE="/tmp/guest_login_command.sh"

if [ -z "$SOCKET" ]
then
  echo "can't find tmux socket, are you running this command from within tmux?"
  exit 1
elif [ -z "$SESSION" ]
then
  echo "can't find tmux session, are you running this command from within tmux?"
  exit 1
fi

sudo rm -rf $GUEST_SOCKET

if [ "$1" == "share" ]
then
  echo "sharing current tmux session"

  sudo passwd guest
  sudo ln $SOCKET $GUEST_SOCKET
  sudo chown $GUEST_USER:$GUEST_USER $GUEST_SOCKET
  sudo chgrp "$GUEST_USER" "$SOCKET"
  sudo chgrp "$GUEST_USER" "$SOCKET_DIR"
  sudo usermod --expiredate "" "$GUEST_USER"
  echo "#!/bin/bash" > $GUEST_LOGIN_FILE
  echo "tmux -S $GUEST_SOCKET attach -t $SESSION" >> $GUEST_LOGIN_FILE
  sudo chgrp "$GUEST_USER" "$GUEST_LOGIN_FILE"
  sudo chmod 750 "$GUEST_LOGIN_FILE"
  echo "to connect \"ssh $GUEST_USER@$HOSTNAME\"" | xsel -ib
else
  echo "unsharing current tmux session"
  chmod 700 "$SOCKET"
  sudo chgrp "$USER" "$SOCKET"
  sudo chgrp "$USER" "$SOCKET_DIR"
  sudo rm -f "$GUEST_LOGIN_FILE"
  echo "disabling guest user"
  sudo usermod --expiredate 1 "$GUEST_USER"
  echo "killing guest processes"
  sudo pkill -u "$GUEST_USER"
fi
