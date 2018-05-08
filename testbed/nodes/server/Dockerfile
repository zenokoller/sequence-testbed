FROM alpine_3.7-transport-measurability:latest

ENV PYTHONPATH /root/python
ENV SERVER_DOMAIN_SERVER_ADDR 172.29.0.2
ENV CLIENT_DOMAIN_CLIENT_ADDR 172.28.0.2

# netemd is launched in the entrypoint script after network interfaces have
# been configured
COPY entrypoint.bash /root/

# Other python packages
RUN pip install aiohttp

# The entrypoint for this container is defined in docker-compose.yml
