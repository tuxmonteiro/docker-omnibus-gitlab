FROM centos:6

MAINTAINER marcelotmonteiro@nospam.com

WORKDIR /root

USER root

ENV RUBY_VER 2.1.2

ENV PKG "autoconf-2.63-5.1.el6.noarch automake-1.11.1-4.el6.noarch bison-2.4.1-5.el6.x86_64 byacc-1.9.20070509-7.el6.x86_64 cmake-2.8.12.2-4.el6.x86_64 crontabs cscope-15.6-7.el6.x86_64 ctags-5.8-2.el6.x86_64 curl curl-devel cvs-1.11.23-16.el6.x86_64 db4-devel diffstat-1.51-2.el6.x86_64 doxygen-1:1.6.1-6.el6.x86_64 expat-devel fakeroot flex-2.5.35-9.el6.x86_64 gcc-4.4.7-17.el6.x86_64 gcc-c++-4.4.7-17.el6.x86_64 gcc-gfortran-4.4.7-17.el6.x86_64 gdbm-devel gettext-0.17-18.el6.x86_64 git2u-2.9.1-1.ius.centos6.x86_64 glibc-devel indent-2.2.10-7.el6.x86_64 intltool-0.41.0-1.1.el6.noarch kernel-devel-2.6.32-642.3.1.el6.x86_64 libcom_err-devel.i686 libcom_err-devel.x86_64 libffi libffi-devel libicu libicu-devel libtool-2.2.6-15.5.el6.x86_64 libxml2 libxml2-devel libxslt libxslt-devel libyaml libyaml-devel logrotate logwatch ncurses-devel nodejs openssl-devel-1.0.1e-48.el6_8.1.x86_64 patchutils-0.3.1-3.1.el6.x86_64 perl-Time-HiRes rcs-5.7-37.el6.x86_64 readline readline-devel-6.0-4.el6.x86_64 rpm-build-4.8.0-55.el6.x86_64 sqlite-devel subversion-1.6.11-15.el6_7.x86_64 sudo-1.8.6p3-24.el6.x86_64 swig-1.3.40-6.el6.x86_64 system-config-firewall-tui systemtap-2.9-4.el6.x86_64 tcl-devel vim-enhanced-2:7.4.629-5.el6.x86_64 wget zlib-devel-1.2.3-29.el6.x86_64"

COPY patches /root/patches

RUN echo "Starting..."; \
  yum install --nogpgcheck -y https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm; \
  yum install --nogpgcheck -y https://centos6.iuscommunity.org/ius-release.rpm; \
  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6; \
  rpm --import /etc/pki/rpm-gpg/IUS-COMMUNITY-GPG-KEY; \
  yum check-update -y; \
  yum install -y ${PKG}; \
  git --version; \
  curl -ks https://storage.googleapis.com/golang/go1.6.3.linux-amd64.tar.gz | tar xvz -C /usr/share/; \
  ln -fs /usr/share/go/bin/* /usr/local/bin/; \
  echo 'export GOROOT=/usr/share/go/' >>  /root/.bash_profile; \
  echo 'export GOPATH="/var/cache/omnibus"' >> /root/.bash_profile; \
  source /root/.bash_profile; \
  /usr/local/bin/go version; \
  git config --global user.email "tuxmonteiro@nospam.com"; \
  git config --global user.name "tuxmonteiro"; \
  git clone https://github.com/rbenv/rbenv.git /root/.rbenv; \
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile; \
  echo 'eval "$(rbenv init -)"' >> ~/.bash_profile; \
  source /root/.bash_profile; \
  git clone https://github.com/rbenv/ruby-build.git /root/.rbenv/plugins/ruby-build; \
  rbenv install ${RUBY_VER}; \
  rbenv global ${RUBY_VER}; \
  gem install --no-doc --no-ri bundler; \
  git clone -b gitlaborg8.10.4+ce.0 https://github.com/tuxmonteiro/omnibus-gitlab.git /root/omnibus-gitlab; \
  mkdir -p /root/omnibus-gitlab/pkg; \
  cd /root/omnibus-gitlab; \
  for p in /root/patches/*patch; do patch -p1 < $p; done; \
  bundle install --path=.bundle --binstubs; \
  sed -i "s%XXXX%$(ls -d /root/omnibus-gitlab/.bundle/ruby/*/bundler/gems/omnibus-* | grep -v software | sed 's|/root/omnibus-gitlab/.bundle/ruby/.*/bundler/gems/omnibus-||')%" /root/patches/post/whitelist.patch; \
  patch -p1 < /root/patches/post/whitelist.patch; \
  echo "Finished."

WORKDIR /root/omnibus-gitlab

VOLUME ["/var/cache/omnibus", "/root/omnibus-gitlab/pkg"]
