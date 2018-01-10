FROM centos:7
#install ssh
RUN yum -y install openssh-server
RUN yum -y install openssh-clients
#generate key
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
#config
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN sed -i 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd
RUN cd ~/.ssh/ && \
         touch config && \
         echo "StrictHostKeyChecking no" >> ~/.ssh/config
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
RUN yum install -y vim telnet net-tools wget mysql mongodb redis 

WORKDIR /home

ENTRYPOINT ["/usr/sbin/sshd"]
EXPOSE 922
CMD ["-D"]
