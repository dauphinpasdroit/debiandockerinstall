mkdir wireguard
cd wireguard

touch docker-compose.yml 

cat <<EOF > docker-compose.yml
version: "3"

services:

  # WireGuard VPN service
  wireguard:
    image: linuxserver/wireguard:latest
    container_name: wireguard
    cap_add:
      - NET_ADMIN
    volumes:
      - ./config:/config
    ports:
      # Port for WireGuard-UI
      - "5000:5000"
      # Port of the WireGuard VPN server
      - "51820:51820/udp"
    restart: unless-stopped

  # WireGuard-UI service
  wireguard-ui:
    image: ngoduykhanh/wireguard-ui:latest
    container_name: wireguard-ui
    depends_on:
      - wireguard
    cap_add:
      - NET_ADMIN
    # Use the network of the 'wireguard' service
    # This enables to show active clients in the status page
    network_mode: service:wireguard
    environment:
      - SENDGRID_API_KEY
      - EMAIL_FROM_ADDRESS
      - EMAIL_FROM_NAME
      - SESSION_SECRET
      - WGUI_USERNAME=admin
      - WGUI_PASSWORD=password
      - WG_CONF_TEMPLATE
      - WGUI_MANAGE_START=true
      - WGUI_MANAGE_RESTART=true
    restart: unless-stopped
    logging:
      driver: json-file
      options:
        max-size: 50m
    volumes:
      - ./db:/app/db
      - ./config:/etc/wireguard
EOF

