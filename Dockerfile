FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Install core display tools and procps utilities
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

# Clone noVNC and pull the touch-friendly interface layer
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc \
    && git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify \
    && cp /opt/novnc/vnc.html /opt/novnc/index.html

RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

WORKDIR $HOME

# 🌟 THE SECRET SAUCE: Native Touch Gestures + Android Agent Flags 🌟
RUN echo '#!/bin/bash\n\
export DISPLAY=:1\n\
Xvfb :1 -screen 0 450x850x24 &\n\
sleep 2\n\
fluxbox &\n\
chromium \\\n\
  --no-sandbox \\\n\
  --disable-dev-shm-usage \\\n\
  --start-maximized \\\n\
  --touch-events=enabled \\\n\
  --force-device-scale-factor=1.5 \\\n\
  --user-agent="Mozilla/5.0 (Linux; Android 13; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36" \\\n\
  --app=https://www.google.com &\n\
sleep 2\n\
x11vnc -display :1 -forever -nopw -listen localhost -shared &\n\
sleep 2\n\
/opt/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 7860\n\
' > $HOME/entrypoint.sh && chmod +x $HOME/entrypoint.sh

EXPOSE 7860

CMD ["/home/user/entrypoint.sh"]
