FROM docker.io/zmkfirmware/zmk-build-arm:stable
RUN apt -y update && apt -y install ssh
#RUN useradd --uid 1000 --create-home builder
WORKDIR /app

# I may use a private zmk branch with ssh-agent, so prevent prompting.
ENV GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"
