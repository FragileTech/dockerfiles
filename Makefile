current_dir = $(shell pwd)

PROJECT = dockerfiles
VERSION ?= latest
DOCKER_TAG = None
PYTHON_VERSION = "3.8"
UBUNTU_NAME = $(lsb_release -s -c)

# Install system packages
.PHONY: install-common-dependencies
install-common-dependencies:
	apt-get update && \
	apt-get install -y --no-install-suggests --no-install-recommends \
		ca-certificates locales pkg-config apt-utils gcc g++ wget make cmake git curl flex ssh gpgv \
		libffi-dev libjpeg-turbo-progs libjpeg8-dev libjpeg-turbo8 libjpeg-turbo8-dev gnupg2 \
		libpng-dev libpng16-16 libglib2.0-0 bison gfortran lsb-release \
		libsm6 libxext6 libxrender1 libfontconfig1 libhdf5-dev libopenblas-base libopenblas-dev \
		libfreetype6 libfreetype6-dev zlib1g-dev zlib1g xvfb python-opengl ffmpeg libhdf5-dev && \
	ln -s /usr/lib/x86_64-linux-gnu/libz.so /lib/ && \
	ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /lib/ && \
	echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
	locale-gen && \
	wget -O - https://bootstrap.pypa.io/get-pip.py | python3 && \
	rm -rf /var/lib/apt/lists/* && \
	echo '#!/bin/bash\n\\n\echo\n\echo "  $@"\n\echo\n\' > /browser && \
	chmod +x /browser

# Install Python 3.9
.PHONY: install-python3.9
install-python3.9:
	apt-get install -y --no-install-suggests --no-install-recommends \
		python3.9 python3.9-dev python3-distutils python3-setuptools

# Install Python 3.8
.PHONY: install-python3.8
install-python3.8:
	apt-get install -y --no-install-suggests --no-install-recommends \
		python3.8 python3.8-dev python3-distutils python3-setuptools

# Install Python 3.7
.PHONY: install-python3.7
install-python3.7:
	apt-get install -y --no-install-suggests --no-install-recommends \
		python3.7 python3.7-dev python3-distutils python3-setuptools

# Install Python 3.6
.PHONY: install-python3.6
install-python3.6:
	apt-get install -y --no-install-suggests --no-install-recommends \
		python3.6 python3.6-dev python3-distutils python3-setuptools \

# Install phantomjs for holoviews image save
.PHONY: install-phantomjs
install-phantomjs:
	curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
	echo "deb https://deb.nodesource.com/node_10.x ${UBUNTU_NAME} main" | tee /etc/apt/sources.list.d/nodesource.list && \
	echo "deb-src https://deb.nodesource.com/node_10.x ${UBUNTU_NAME} main" | tee -a /etc/apt/sources.list.d/nodesource.list && \
	apt-get update && apt-get install -y nodejs && \
	npm install phantomjs --unsafe-perm && \
	npm install -g phantomjs-prebuilt --unsafe-perm

# Install common python dependencies
.PHONY: install-python-libs
install-python-libs:
	pip3 install -U pip && \
	pip3 install --no-cache-dir setuptools wheel cython ipython jupyter pipenv && \
	pip3 install --no-cache-dir matplotlib && \
	python3 -c "import matplotlib; matplotlib.use('Agg'); import matplotlib.pyplot"



.PHONY: remove-dev-packages
remove-dev-packages:
	pip3 uninstall -y cython && \
	apt-get remove -y cmake pkg-config flex bison curl libpng-dev \
		libjpeg-turbo8-dev zlib1g-dev libhdf5-dev libopenblas-dev gfortran \
		libfreetype6-dev libjpeg8-dev libffi-dev && \
	apt-get autoremove -y && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

.PHONY: docker-push
docker-push:
	docker push fragiletech/${DOCKER_TAG}:${VERSION}
	docker tag fragiletech/${DOCKER_TAG}:${VERSION} fragiletech/${DOCKER_TAG}:latest
	docker push fragiletech/${DOCKER_TAG}:latest


