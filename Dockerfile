FROM alpine:3

# Variables set with ARG can be overridden at image build time with
# "--build-arg var=value".  They are not available in the running container.
ARG restic_ver=0.15.2
ARG tfc_ops_ver=3.5.1
ARG tfc_ops_distrib=tfc-ops_${tfc_ops_ver}_Linux_x86_64.tar.gz

# Install Restic, tfc-ops, perl, and jq
RUN cd /tmp \
 && wget -O /tmp/restic.bz2 \
    https://github.com/restic/restic/releases/download/v${restic_ver}/restic_${restic_ver}_linux_amd64.bz2 \
 && bunzip2 /tmp/restic.bz2 \
 && chmod +x /tmp/restic \
 && mv /tmp/restic /usr/local/bin/restic \
 && wget https://github.com/silinternational/tfc-ops/releases/download/v${tfc_ops_ver}/${tfc_ops_distrib} \
 && tar zxf ${tfc_ops_distrib} \
 && rm LICENSE README.md ${tfc_ops_distrib} \
 && mv tfc-ops /usr/local/bin \
 && apk update \
 && apk add --no-cache perl jq curl \
 && rm -rf /var/cache/apk/*

COPY ./tfc-backup.sh  /usr/local/bin/tfc-backup.sh
COPY ./tfc-dump.pl    /usr/local/bin/tfc-dump.pl
COPY application/     /data/

WORKDIR /data

CMD [ "/usr/local/bin/tfc-backup.sh" ]
