#/bin/sh
username=root
if [ ! -z "$PGID" ] && [ ! -z "$PUID" ]
then
    groupadd -g $PGID slsk
    useradd -u $PUID -g $PGID slsk -d /slsk -s /bin/bash
    username=slsk
else
    mkdir /slsk
fi
chown -R $username /squashfs-root
resolution=${resolution:-1280x720}x16
[ "$resize" = "auto" ] && sed -r -i '/src/s/"[^"]+"/"vnc.html?autoconnect=true"/' /usr/share/novnc/index.html
[ "$resize" = "scale" ] && sed -r -i '/src/s/"[^"]+"/"vnc.html?autoconnect=true\&resize=scale"/' /usr/share/novnc/index.html
[ "$resize" = "remote" ] && sed -r -i '/src/s/"[^"]+"/"vnc.html?autoconnect=true\&resize=remote"/' /usr/share/novnc/index.html
[ ! -f /etc/supervisord.conf ] && echo "[supervisord]
nodaemon=true

[program:xvfb]
command=/usr/bin/Xvfb :1 -screen 0 $resolution
autorestart=true
priority=100

[program:x11vnc]
command=/usr/bin/x11vnc -xkb -noxrecord -noxfixes -noxdamage -display :1 -nopw -wait 5 -shared -permitfiletransfer -tightfilexfer -rfbport 5900
autorestart=true
priority=200

[program:openbox]
environment=HOME="/slsk",DISPLAY=":1",USER="$username"
command=/usr/bin/openbox
autorestart=true
priority=300

[program:novnc]
command=/usr/share/novnc/utils/launch.sh
autorestart=true
priority=400

[program:soulseek]
environment=HOME="/slsk",DISPLAY=":1",USER="$username"
command=/squashfs-root/SoulseekQt
user=$username
autorestart=true
priority=500" > /etc/supervisord.conf
/usr/bin/supervisord -c /etc/supervisord.conf
