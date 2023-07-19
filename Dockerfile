FROM alpine:3.18

ENV TFC_OPS_VER="3.5.1"
ENV TFC_OPS_DISTRIB="tfc-ops_${TFC_OPS_VER}_Linux_x86_64.tar.gz"

COPY ./dump-and-save.sh  /usr/local/bin/dump-and-save.sh
COPY ./tfc-dump.pl       /usr/local/bin/tfc-dump.pl

# Install tfc-ops, 1Password CLI, perl, and jq
RUN cd /tmp \
 && wget https://github.com/silinternational/tfc-ops/releases/download/v${TFC_OPS_VER}/${TFC_OPS_DISTRIB} \
 && tar zxf ${TFC_OPS_DISTRIB} \
 && rm LICENSE README.md ${TFC_OPS_DISTRIB} \
 && mv tfc-ops /usr/local/bin \
 && chmod +x /usr/local/bin/tfc-ops \
 && echo https://downloads.1password.com/linux/alpinelinux/stable/ >> /etc/apk/repositories \
 && wget https://downloads.1password.com/linux/keys/alpinelinux/support@1password.com-61ddfc31.rsa.pub -P /etc/apk/keys \
 && apk update \
 && apk add 1password-cli perl jq curl

ENTRYPOINT /usr/local/bin/dump-and-save.sh
