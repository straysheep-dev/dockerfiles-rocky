# Dockerfile for rockylinux/rockylinux:latest
# SPDX-License-Identifier: MIT
#
# Built from the following sources:
# - https://github.com/geerlingguy/docker-fedora42-ansible/blob/master/Dockerfile
# - https://github.com/geerlingguy/docker-rockylinux9-ansible/blob/master/Dockerfile
# - https://hub.docker.com/r/rockylinux/rockylinux
# - https://ansible.readthedocs.io/projects/molecule/guides/systemd-container/
#
# Dockerfile reference: https://docs.docker.com/reference/dockerfile/
FROM rockylinux/rockylinux:latest

# Tells components like systemd they're running in Docker
ENV container=docker

RUN dnf -y update && dnf clean all

# Enable systemd.
RUN dnf -y install systemd && dnf clean all && \
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install packages
# Including python3-rpm resolves issues with package_facts enumeration.
# dnf and dnf5 are aliases to rpm for the package_facts module, which points
# to the python3-rpm library for the required RPM bindings.
# - https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_facts_module.html#parameter-manager
# - https://github.com/ansible/ansible/issues/84834
#
# Rocky Linux also has no python3-libdnf5 package.
#
# This Dockerfile also includes the epel-release repository.
# - https://docs.rockylinux.org/books/admin_guide/13-softwares/#the-epel-repository
RUN dnf -y install \
    python3-pip \
    python3-rpm \
    sudo \
    which \
    epel-release \
    && dnf clean all

# This is required to avoid errors when installing Ansible in the next step
RUN python3 -m pip install --upgrade pip

# Install Ansible via Pip.
RUN python3 -m pip install --user ansible

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo -e "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Required for systemd in Docker
VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/usr/sbin/init"]
