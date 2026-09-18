#!/usr/bin/env bash
if [ -d "/run/user/1000" ]; then
    /usr/bin/su - ryie -c "XDG_RUNTIME_DIR=/run/user/1000 systemctl --user restart noisetorch.service" >/dev/null 2>&1 &
fi
