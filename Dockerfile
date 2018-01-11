FROM centos:7
ENV OS centos7

#config systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

#install ssh
RUN yum -y install openssh-server openssh-clients
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key
RUN sed -i '/DNS/a\UseDNS no' /etc/ssh/sshd_config
RUN sed -i '/#Port 22/a\Port 922' /etc/ssh/sshd_config

#set root login password
RUN yum install -y passwd openssl
RUN (echo "adminpass";sleep 1;echo "adminpass") | passwd > /dev/null

#install docker
RUN yum install -y lrzsz docker
#install oc
ADD oc /usr/local/bin/oc
RUN chmod +x /usr/local/bin/oc
#install other tools
RUN yum install -y vim telnet iproute net-tools wget mysql mongodb redis 

WORKDIR /home

ENTRYPOINT ["/usr/sbin/sshd"]
EXPOSE 922
CMD ["-D"]
