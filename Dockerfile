FROM mambaorg/micromamba:1.5.9-jammy

COPY --chown=$MAMBA_USER:$MAMBA_USER env/*.yml /tmp/

RUN mkdir -p /home/mnt && \
    micromamba install -yn base -f /tmp/base.yml && \
    micromamba create -yf /tmp/rgi.yml && \
    micromamba clean -ya && \
    rm /tmp/*.yml

WORKDIR /home/mnt
