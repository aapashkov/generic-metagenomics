FROM mambaorg/micromamba:1.5.1

# Download system requirements
USER root
RUN apt update && \
    apt install -y git wget bzip2 && \
    wget -q https://mirrors.kernel.org/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb && \
    apt install -y ./libffi6_3.2.1-8_amd64.deb && \
    rm -rf /var/lib/apt/lists/* /var/log/dpkg.log libffi6_3.2.1-8_amd64.deb

# Create virtual environments
USER $MAMBA_USER
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yml /tmp/env.yml
COPY --chown=$MAMBA_USER:$MAMBA_USER rgi.yml /tmp/rgi.yml
RUN mkdir -p /home/mnt && \
    micromamba install -yn base -f /tmp/env.yml && \
    micromamba create -yf /tmp/rgi.yml && \
    micromamba clean -ya && \
    rm /tmp/env.yml /tmp/rgi.yml

# Add RGI to PATH
RUN echo "micromamba run -n rgi rgi \$@" > /opt/conda/bin/rgi && \
    chmod +x /opt/conda/bin/rgi && \
    wget -qO - "https://card.mcmaster.ca/download/0/broadstreet-v3.2.8.tar.bz2" | \
        tar -C /tmp/ -xjf - ./card.json && \
    /opt/conda/envs/rgi/bin/rgi load -i /tmp/card.json && \
    rm /tmp/card.json

WORKDIR /home/mnt
