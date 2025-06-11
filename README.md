# gcontainer
Gaming Container

podman run -d \
  --runtime crun \
  --device /dev/dri \
  --device /dev/uinput \
  --device /dev/uhid \
  --name=test \
  --restart=unless-stopped \
  --userns=keep-id \
  --group-add keep-groups \
  -p 47984-47990:47984-47990/tcp \
  -p 48010:48010 \
  -p 47998-48000:47998-48000/udp \
  localhost/local:latest

Init
https://github.com/just-containers/s6-overlay?tab=readme-ov-file#quickstart/dev/input/:/dev/input/:ro