FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    fluxbox \
    dbus-x11 \
    chromium \
    procps \
    git \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/novnc/noVNC.git /opt/novnc \
    && git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify \
    && cp /opt/novnc/vnc.html /opt/novnc/index.html

RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

WORKDIR $HOME

RUN echo '#!/bin/bash\n\
export DISPLAY=:1\n\
Xvfb :1 -screen 0 1280x720x24 &\n\
sleep 2\n\
fluxbox &\n\
chromium --no-sandbox --disable-dev-shm-usage --start-maximized &\n\
x11vnc -display :1 -forever -nopw -listen localhost -shared &\n\
sleep 2\n\
/opt/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 7860\n\
' > $HOME/entrypoint.sh && chmod +x $HOME/entrypoint.sh

EXPOSE 7860

CMD ["/home/user/entrypoint.sh"]
