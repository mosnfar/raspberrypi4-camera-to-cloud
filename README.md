# How to stream raspberry pi feed to cloud

Connecting a camera to a Raspberry Pi through the on-board camera port or USB port can assist in capturing images or videos. This setup can serve various purposes. In this repository, you can find a prebuilt shell script designed to facilitate continuous image streaming to online cloud services such as Google Drive for Linux-operated Raspberry Pi.

## Use cases

- Online Stream of Camera
- Frame Capture for Timelaps

## How to use

First of all you should install dependencies like "ffmpeg", "rclone". To do it use command below:
`sudo apt update && sudo apt install ffmpeg rclone`



RESOURCES: [Using USB Webcam](https://raspberrypi-guide.github.io/electronics/using-usb-webcams), [Use rclone for Google Drive](https://www.baeldung.com/linux/google-drive-guide#2-rclone), [rclone, Google Drive](https://rclone.org/drive/)