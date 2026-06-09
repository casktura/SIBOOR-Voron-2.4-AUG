# Readme

## References

- [Siboor 2.4R2 AUG](https://docs.siboor.com/siboor-2.4-r2-aug)
- [Klipper Documentation](https://www.klipper3d.org/)
- [KIAUH](https://github.com/dw-0/kiauh)
- [Katapult](https://github.com/Arksine/katapult)
- [Using CAN Bus with systemd-networkd](https://maz0r.github.io/klipper_canbus/extras/systemd-networkd.html)
- [Armbian Image](https://armbian.com/boards/bigtreetech-cb1)
- [Cartographer 3D](https://docs.cartographer3d.com/)
- **NOT NEEDED** [Armbian Firstboot Config](https://docs.armbian.com/User-Guide_Autoconfig/)
- **NOT NEEDED** [Sonar](https://github.com/mainsail-crew/sonar)

## Settings

### Armbian

- Root
    - Username: `root`
    - Password: `password`
- User
    - Name: `Armbian`
    - Username: `armbian`
    - Password: `password`
- Locale: `en_US.UTF-8`
- Time Zone: `Asia/Bangkok`
- `wlan1`
    - Mac Address: `de:84:03:e8:cd:cf`
    - `May`
        - IP Address: `192.168.68.64`

### Klipper

- Octopus Pro: `1e691b91fae3`
- EBB: `747323232eb7`
- Cartographer: `14c8757f4532`

## Editing File in Linux

1. Run: `sudo vim /path/to/file.txt`
2. Type `:wq` to save and exit.

### Vim Commands

- Force exit with out saving: `:q!`

## Armbian

1. If Armbian firsboot config is not working properly, configure Wi-Fi with `armbian-config`
    - Interface: `wlan1`
    - MAC Address: `de:84:03:e8:cd:cf`
2. Update and install dependencies with `sudo apt update` then `sudo apt install git vim python3-serial`
3. Set up CAN bus in networkd:
    - Check if your systemd supports CAN bus: `systemctl --version`, systemd with version 239 or higher is good to go.
    - Add settings below to file `/etc/systemd/network/80-can.network`:

        ```
        [Match]
        Name=can0

        [CAN]
        BitRate=1000000
        ```

    - Add settings below to file `/etc/systemd/network/80-can.link`:

        ```
        [Match]
        Type=can

        [Link]
        TransmitQueueLength=128
        ```

    - Reboot: `sudo reboot`
    - Check systemd-networkd status: `sudo systemctl status systemd-networkd`
    - Check queue length: `ip link show can0`, continue below if qlen is not 128.
        - Add settings below to file `/etc/udev/rules.d/99-canbus.rules`:

            ```
            # Set tx queue size for CAN bus.
            SUBSYSTEM=="net", ACTION=="add|change", KERNEL=="can0" ATTR{tx_queue_len}="128"
            ```

        - Reboot

4. Install Klipper with [KIAUH](https://github.com/dw-0/kiauh):
    - `cd ~ && git clone https://github.com/dw-0/kiauh.git`
    - `./kiauh/kiauh.sh`
    - Then install components in order:
        1. Klipper
        2. Moonraker
        3. Mainsail
        4. KlipperScreen
            - **Skip NetworkManager.**
        5. Advanced/Input Shaper
5. Install [Cartographer3D](https://docs.cartographer3d.com/cartographer-probe/installation-and-setup/software-configuration/klipper-setup) Klipper plugin.
    ```bash
    curl -s -L https://raw.githubusercontent.com/Cartographer3D/cartographer3d-plugin/refs/heads/main/scripts/install.sh | bash -s -- --klipper ~/klipper --klippy-env ~/klippy-env
    ```
6. Clone Cartographer3D firmware repository: `git clone https://github.com/Cartographer3D/cartographer_firmware.git`
7. Clone Katapult: `git clone https://github.com/Arksine/katapult`

## Katapult & Klipper

- To configure: `make menuconfig`
- To make: `make`
- Output files will be in `~/<katapult/klipper>/out` folder.
- Stop Kliper before flashing firmware and start again after.

### Octopus Pro

1. Enter Octopus Pro DFU mode using CAN bus:

    ```
    ~/klippy-env/bin/python ~/katapult/scripts/flashtool.py -i can0 -u 1e691b91fae3 -r -f octopus_klipper.bin
    ```

2. Flash Klipper:

    ```
    ~/klippy-env/bin/python ~/katapult/scripts/flashtool.py -d <serial/device/path> -f octopus_klipper.bin
    ```

    Sometimes, serial device path can be seen from the result of step 1, for example `/dev/ttyACM0`.

3. You can also flash Katapult using make itself:

    ```
    sudo make flash FLASH_DEVICE=0483:df11
    ```

    Look for flash device using `lsusb`.

### EBB SB2209 CAN RP2040

```
~/klippy-env/bin/python ~/katapult/scripts/flash_can.py -i can0 -u 747323232eb7 -f ebb_klipper.bin
```

## Commands

- Configure Armbian basic settings: `armbian-config`
- View disk space and usage: `df -h`
- List USB devices: `lsusb`
- List network interfaces and basic stats: `ip a` or `ip addr`
- List available CAN uuids (only devices not configured in printer.cfg file): `~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0`
- Check if system has ifconfig or systemd-networkd:
    - `ifconfig`
    - `systemctl status systemd-networkd`
- Check NetworkManager interfaces status: `nmcli device status`
- Reboot: `sudo reboot`
- Download file from server:

    ```bash
    scp username@remote_host:/path/to/remote/file /path/to/local/destination

    # Windows example.
    scp user@host:/remote/source/path/file C:\target\local\path\file
    ```

- Services control
    - Services name
        - `klipper`
        - `sonar`
    - Check status: `sudo service service_name status`
    - Start: `sudo service service_name start`
    - Stop: `sudo service service_name stop`
- Tuning, run in Mainsail console.
    - PID tune heated bed: `PID_CALIBRATE HEATER=heater_bed TARGET=100`
    - PID tune hotend: `PID_CALIBRATE HEATER=extruder TARGET=245`
- KlipperScreen
    - Exit KlipperScreen press: `Ctrl + Alt + F1`
    - Return to KlipperScreen press: `Ctrl + Alt + F2`

## Versions

- BTT PI: `1.2.1`
- BTT Octopus Pro: `1.0.1`, `446` variant.
- BTT HDMI5: `1.2`
- Cartographer
    - Hardware: `V3`
    - Firmware: `6.1.0`

## Notes:

- Prime numbers from 0 to 100:
    ```
    2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97,
    101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199,
    211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293,
    307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397
    ```
- Position for belt tuning: `X:150 Y:112 Z:175`
