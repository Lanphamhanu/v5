# Use a Linux-based image compatible with Render
FROM ubuntu:latest

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Download ngrok
RUN wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -O ngrok.zip \
    && unzip ngrok.zip -d /usr/local/bin \
    && rm ngrok.zip

# Set ngrok authentication token (replace NGROK_AUTH_TOKEN with your actual token)
ARG NGROK_AUTH_TOKEN
ENV NGROK_AUTH_TOKEN=$NGROK_AUTH_TOKEN
RUN /usr/local/bin/ngrok authtoken $NGROK_AUTH_TOKEN

# Expose the necessary ports (if any)
EXPOSE 3389

# Run ngrok to expose RDP port (replace 3389 with the desired port)
CMD ["/usr/local/bin/ngrok", "tcp", "3389"]
