FROM centos:centos7 as os

RUN yum install -y -q java-1.8.0-openjdk-devel && \
    yum install -y -q epel-release && \
    yum clean all && rm -rf /var/cache/yum

ARG version=2.0.0.2

RUN cd /opt && \
    curl -sSL https://codeload.github.com/yahoo/CMAK/tar.gz/${version} -o CMAK.tar.gz && \
    tar -xzf CMAK.tar.gz && \
    mv CMAK-${version} CMAK && \
    rm -f CMAK.tar.gz && \
    cd CMAK && \
    # -z  判断 变量的值，是否为空, 为空，返回0，为true,非空，返回1，为false
    # yes 需要输入用户输入y/n时，输入 y;yes r 将 y 替换为 r
    # 1 标准输出，2 标准错误， 1>&2,输出到同一个文件
    while [[ -z $(yes r | ./sbt clean dist 1>&2 && echo "ok") ]]; do echo "retry sbt"; done && \
    rm -rf ~/.ivy2 ~/.pki ~/.sbt && \
    cd /opt && \
    mv CMAK/target/universal/cmak-${version}.zip ./ && \
    rm -rf CMAK && \
    ls -l -h cmak-${version}.zip && \
    md5sum cmak-${version}.zip