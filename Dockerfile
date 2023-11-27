FROM mambaorg/micromamba:1.5.1

USER root
RUN apt update && \
    apt install -y git  && \
    rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

USER $MAMBA_USER
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yml /tmp/env.yml
RUN mkdir -p /home/mnt && \
    micromamba install -yn base -f /tmp/env.yml && \
    micromamba clean -ya && \
    rm /tmp/env.yml

WORKDIR /home/mnt
ENTRYPOINT "/bin/bash -c"
