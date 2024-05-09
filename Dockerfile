# Use the official Windows Server Core image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Download and install Chocolatey
RUN powershell -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install unzip package
RUN choco install -y unzip

# Download ngrok and unzip
RUN powershell -Command \
    Invoke-WebRequest https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip -OutFile ngrok.zip; \
    Expand-Archive ngrok.zip -DestinationPath C:\ngrok

# Set ngrok authentication token
ARG NGROK_AUTH_TOKEN
ENV NGROK_AUTH_TOKEN=$NGROK_AUTH_TOKEN
RUN powershell -Command \
    .\ngrok\ngrok.exe authtoken $Env:NGROK_AUTH_TOKEN

# Enable Terminal Services
RUN powershell -Command \
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0; \
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"; \
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 1; \
    Set-LocalUser -Name "runneradmin" -Password (ConvertTo-SecureString -AsPlainText "P@ssw0rd!" -Force)

# Expose RDP port using ngrok
CMD ["powershell", "-Command", ".\ngrok\ngrok.exe tcp 3389"]
