# Docker image for programming ESP microcontrollers

## How it started

Recently I tried to flash a [Sonoff POW Elite](https://sonoff.tech/product/diy-smart-switches/pow-elite)
with the latest [Tasmota](https://www.tasmota.info/) firmware
, to unlock it from the Sonoff cloud and put the control
of the device directly into my hands. I had done this a couple of times before with other devices,
with no problems, but this one showed up to be uncooperative.
Some posts on the web pointed into the direction that this could have to do with the flashing tool,
so I tried to use another computer and the recommended esptool.py, freshly installed.

But upon installation, my Cygwin had trouble with several dependencies. Nerved by this and unwilling to mess up another
computer with lots of software packages I probably wouldn't need after this project, I opted for a different way, one with a
proper cleanup after all is done: using the esptool.py from within a docker image.


## Building the docker image

Surprisingly, this was uncomplicated and done with a couple of minutes. So, not to waste time, here's the simple but working
dockerfile, based on the latest Ubuntu image. It just pulls the updates and python3 with pip, so that the latter can install
the esptool.

```
# Define base image; Ubuntu is always a good choice
FROM ubuntu:latest

# get the latest updates for the base image 
RUN apt-get update

# Install python3-pip, which instales python3 automatically
RUN apt-get -y install python3-pip

# Use pip to install esptool.py
RUN pip install esptool
```

I've built my image with this line:

`docker build -t esptool:1.1  - <Dockerfile`


## Usage
First, this is not a documentation how to flash a specific device. It's just shown how to use esptool.py by running
it in a docker container. Please refer to the documentation of your device and project that you wish to flash.

Second, make sure that your serial programmer is connected properly to a USB port and it's visible to the system.
Usually it should be /dev/ttyUSB0 oder /dev/ttyUSB1.

Third, place the firmware you want to flash in the current directory. Once you have built the image, connect your
ESP device and put it into download mode. With the following command you may check if everything works as desired:

`docker run --rm --device=/dev/ttyUSB0 -v $(pwd):/outside  esptool:1.1 esptool.py --port /dev/ttyUSB0 flash_id`

The command
* starts a non-permanent (`--rm`) container,
* passes through the serial device (in my case `/dev/ttyUSB0`) into the container,
* mounts the current directory inside the container at `/outside`
* and starts the `esptool.py`
* which reads chip information etc. from your ESP device.

If everything works fine, you may use the following command (or similar, depending on your projects needs) to write
the binary to the ESP board:

`docker run --rm --device=/dev/ttyUSB0 -v $(pwd):/outside esptool:1.0 esptool.py --port /dev/ttyUSB0 write_flash  0x0 /outside/tasmota32.factory.bin`

Once everything is done, you just have to remove the image again:

`docker rmi esptool:1.1`

## Pro/contra

Advantages:
* No need to mess up your computer with otherwise unneeded software packages
* or maybe even struggle with dependencies or versions that conflict with other projects you're working on.

Disadvantages:
* You need [Docker](https://www.docker.com/) installed and the daemon running.
* This way needs more (temporary) diskspace, as the image might grow to 505 MB.

## Sonoff POW Elite
A last word about the above mentioned Sonoff POW Elite, often also refered to as POWR316D. I tried to
flash it using the documention at [bangertech.de](https://bangertech.de/sonoff-pow-elite/) and failed
several times, both using esptool and the [Tasmota web installer ](https://tasmota.github.io/install/)
on several browser. It never woulöd show up with a working wifi access point.

At least, I was able to hook up a serial line for debugging and found the following lines repeating in the boot log:
`
rst:0x10 (RTCWDT_RTC_RESET),boot:0x13 (SPI_FAST_FLASH_BOOT)
invalid header: 0x2e000000
invalid header: 0x2e000000
invalid header: 0x2e000000
...
`

Research on the web didn't show much hints what could be the cause. So I decided to follow a
recommendation Theo Arends gives for first time flashing a device: use the *factory binaries*.

Simple but effectiv, it worked. After flashing the default factory firmware, the Sonoff device
came up with a wifi access point and I was able to first configure and after that update it using
the built-in *ota update* feature.



## Links
Related repositories
* [Tasmota](https://tasmota.github.io/docs/)
* [esptool](https://github.com/espressif/esptool)

More documentaion:
* [Getting started with Tasmota](https://tasmota.github.io/docs/Getting-Started/)
* [Different ways and tools to install Tasmota](https://peyanski.com/how-to-install-tasmota-nowadays/)

