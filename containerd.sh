#!/bin/bash

curl -Ls -O https://github.com/containerd/containerd/releases/download/v2.2.0/containerd-2.2.0-linux-amd64.tar.gz
curl -Ls -O https://github.com/containerd/containerd/releases/download/v2.2.0/containerd-2.2.0-linux-amd64.tar.gz.sha256sum
sha256sum -c containerd-2.2.0-linux-amd64.tar.gz.sha256sum

tar Cxzvf /usr/local containerd-2.2.0-linux-amd64.tar.gz

tee /lib/systemd/system/containerd.service >/dev/null <<'EOF'
# Copyright The containerd Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target dbus.service

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity

# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF

curl -Ls -O https://github.com/opencontainers/runc/releases/download/v1.3.3/runc.amd64
curl -Ls -O https://github.com/opencontainers/runc/releases/download/v1.3.3/runc.sha256sum
grep runc.amd64 runc.sha256sum | sha256sum -c -
install -m 755 runc.amd64 /usr/local/bin/runc

curl -Ls -O https://github.com/containernetworking/plugins/releases/download/v1.8.0/cni-plugins-linux-amd64-v1.8.0.tgz
curl -Ls -O https://github.com/containernetworking/plugins/releases/download/v1.8.0/cni-plugins-linux-amd64-v1.8.0.tgz.sha256
sha256sum -c cni-plugins-linux-amd64-v1.8.0.tgz.sha256
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.8.0.tgz

curl -Ls -O https://github.com/containerd/nerdctl/releases/download/v2.2.0/nerdctl-2.2.0-linux-amd64.tar.gz
grep nerdctl-2.2.0-linux-amd64.tar.gz SHA256SUMS | sha256sum -c -
tar Cxzvf /usr/local/bin nerdctl-2.2.0-linux-amd64.tar.gz

curl -Ls -O https://github.com/moby/buildkit/releases/download/v0.26.0/buildkit-v0.26.0.linux-amd64.tar.gz
tar Cxzvf /usr/local buildkit-v0.26.0.linux-amd64.tar.gz
