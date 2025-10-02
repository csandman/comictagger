FROM ghcr.io/linuxserver/unrar:latest AS unrar
FROM lscr.io/linuxserver/webtop:ubuntu-openbox

# 1. install build deps & python runtime
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends python3-venv python3-pip python3-pyqt6 python3-dev libffi-dev pkg-config libicu-dev build-essential wmctrl libxcb-cursor0 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /root/.cache

# 2. set up virtualenv and ComicTagger (GUI+CBR)
RUN python3 -m venv /opt/comictagger-venv && /opt/comictagger-venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel && /opt/comictagger-venv/bin/pip install --no-cache-dir --pre "comictagger[GUI,CBR]==1.6.0b6"

# 3. remove build deps
RUN apt-get purge -y --auto-remove python3-dev libffi-dev pkg-config libicu-dev build-essential && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /root/.cache

# 3.1 add unrar
COPY --from=unrar /usr/bin/unrar-ubuntu /usr/bin/unrar

# 4. launch ComicTagger
RUN printf '%s\n' '#!/bin/bash' 'export PATH=/opt/comictagger-venv/bin:$$PATH' 'sleep 2' 'comictagger &' 'sleep 2' \
  'wmctrl -r "ComicTagger" -b add,fullscreen' > /defaults/autostart && chmod +x /defaults/autostart
