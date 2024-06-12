FROM debian:bookworm

RUN apt update && apt install -y --no-install-recommends gnupg

RUN echo "deb http://archive.raspberrypi.org/debian/ bookworm main" > /etc/apt/sources.list.d/raspi.list \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 82B129927FA3303E

RUN apt update && apt -y upgrade

RUN apt update && apt install -y --no-install-recommends \
        python3-dev \
        python3-pip \
        python3-picamera2 \
        python3-pygame \
        gcc \
        libsdl1.2debian \
        libportmidi-dev \
        libsdl-ttf2.0-0 \
        libsdl-mixer1.2 \
        libsdl-image1.2 \
        libsmpeg0 \
        libfreetype6 \
     && apt-get clean \
     && apt-get autoremove \
     && rm -rf /var/cache/apt/archives/* \
     && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

# set the version using a variable
ARG RTIMULIB_VERSION=7.2.1-6
ARG SENSE_HAT_VERSION=2.6.0-1
ARG ARCH=arm64

RUN apt update && apt install -y --no-install-recommends \
    curl \
    python3-smbus \
    python3-rtimulib \
     && apt-get clean \
     && apt-get autoremove \
     && rm -rf /var/cache/apt/archives/* \
     && rm -rf /var/lib/apt/lists/*

# get all th required libraries
RUN curl -LO https://archive.raspberrypi.org/debian/pool/main/r/rtimulib/librtimulib-dev_${RTIMULIB_VERSION}_${ARCH}.deb \
 && curl -LO https://archive.raspberrypi.org/debian/pool/main/r/rtimulib/librtimulib-utils_${RTIMULIB_VERSION}_${ARCH}.deb \
 && curl -LO https://archive.raspberrypi.org/debian/pool/main/r/rtimulib/librtimulib7_${RTIMULIB_VERSION}_${ARCH}.deb \
 && curl -LO https://archive.raspberrypi.org/debian/pool/main/p/python-sense-hat/python3-sense-hat_${SENSE_HAT_VERSION}_all.deb

# install the required libraries
RUN dpkg -i \
    librtimulib-dev_${RTIMULIB_VERSION}_${ARCH}.deb \
    librtimulib-utils_${RTIMULIB_VERSION}_${ARCH}.deb \
    librtimulib7_${RTIMULIB_VERSION}_${ARCH}.deb \
    python3-sense-hat_${SENSE_HAT_VERSION}_all.deb

# cleanups
RUN rm -f /tmp/*.deb \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------------------------------------------
# Build and run application
# ------------------------------------------------------------------------------------------------
# Set the working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --break-system-packages --no-cache-dir -r requirements.txt

# Copy the Python files
COPY src /app/

ENV PYTHONPATH "${PYTHONPATH}:/app/rpi_ups"

ENV PYTHONUNBUFFERED=1
