FROM ubuntu:20.04 AS builder
WORKDIR /opt
ENV DEBIAN_FRONTEND=noninteractive
# host ip: host.docker.internal
# ENV HTTPS_PROXY="http://host.docker.internal:2802"
# ENV HTTP_PROXY="http://host.docker.internal:2802"
# ENV https_proxy="http://host.docker.internal:2802"
# ENV http_proxy="http://host.docker.internal:2802"
RUN cd /opt \
    # && sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
    && apt update \
    && apt install nano bash wget -y \
    && apt install build-essential libncurses5 libncurses5-dev git python unzip bc squashfs-tools cpio rsync mercurial cmake -y \
    # buildroot
    && git clone https://github.com/retrofw/buildroot.git \
    && cd /opt/buildroot \
    && make RetroFW_defconfig BR2_EXTERNAL=retrofw \
    && export FORCE_UNSAFE_CONFIGURE=1 \
    && make \
    && mkdir /opt/retrofwtools \
    # put toolchain into path
    && echo "export PATH=/opt/buildroot/output/host/mipsel-RetroFW-linux-uclibc/sysroot/usr/bin:\$PATH" > /etc/profile.d/retrofwtools.sh \
    && echo "export PATH=/opt/buildroot/output/host/bin:\$PATH" >> /etc/profile.d/retrofwtools.sh \
    && cp /etc/profile.d/retrofwtools.sh /opt

FROM ubuntu:20.04 AS release
COPY --from=builder /opt/buildroot/output/host /opt/buildroot/output/host
COPY --from=builder /opt/retrofwtools.sh /opt
ENV DEBIAN_FRONTEND=noninteractive
RUN cd / \
    && chmod +x /opt/retrofwtools.sh
ENV PATH="/opt/buildroot/output/host/bin:/opt/buildroot/output/host/mipsel-RetroFW-linux-uclibc/sysroot/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
