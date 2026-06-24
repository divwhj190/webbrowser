# Pull an officially optimized container built specifically for low-latency WebRTC streams
FROM kasmweb/chromium:1.15.0

# Strip out the desktop login panel for seamless loading inside the Google Script
ENV VNC_PW=
ENV LAUNCH_URL=https://www.google.com

# Force Kasm's internal WebRTC routing engine onto your Codespace port
ENV KASM_PORT=7860

# Force the layout to be vertical and responsively scaled for mobile screens
ENV DESKTOP_WIDTH=450
ENV DESKTOP_HEIGHT=850

EXPOSE 7860
