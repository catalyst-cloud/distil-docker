# Copyright (C) 2024 Catalyst Cloud Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Ubuntu 22.04 with Python 3.10.
FROM ubuntu:22.04

ARG DISTIL_REPOSITORY="https://review.opendev.org/x/distil.git"
ARG DISTIL_VERSION="refs/changes/05/920005/1"

ARG UPPER_CONSTRAINTS_URL="https://releases.openstack.org/constraints/upper/master"

ARG UID="1000"
ARG GID="1000"

ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/distil/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

# netbase is required for the Python socket package to work.
# libssl is required for HTTPS support in uWSGI.
# git is required to pull git repositories using pip.
# build-essential and libpython3-dev are required to compile some binary wheels from source.
RUN apt-get update && \
    apt-get install -y python3 \
                       python3-pip \
                       python3-virtualenv \
                       netbase \
                       libpython3.10 \
                       libssl3 \
                       git \
                       build-essential \
                       libpython3-dev \
                       libssl-dev && \
    python3 -m virtualenv /opt/distil && \
    /opt/distil/bin/python -m pip install --no-cache-dir \
                                          -c "${UPPER_CONSTRAINTS_URL}" \
                                          "distil @ git+${DISTIL_REPOSITORY}@${DISTIL_VERSION}" \
                                          uwsgi && \
    apt-get purge --auto-remove -y git build-essential libpython3-dev libssl-dev && \
    groupadd --gid "${GID}" distil && \
    useradd --uid "${UID}" --gid "${GID}" --shell /bin/bash distil

USER distil:distil
