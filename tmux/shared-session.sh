#!/bin/bash
tmux -S /var/tmux/shared attach-session || (tmux -S /var/tmux/shared new-session && chgrp users /var/tmux/shared && chmod g+rw /var/tmux/shared && ls /home | xargs -i tmux -S /var/tmux/shared server-access -a {})
