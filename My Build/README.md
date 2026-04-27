# Readme

## References

- [Klipper Documentation](https://www.klipper3d.org/)
- [KIAUH](https://github.com/dw-0/kiauh)
- [Katapult](https://github.com/Arksine/katapult)
- [Using CAN Bus with systemd-networkd](https://maz0r.github.io/klipper_canbus/extras/systemd-networkd.html)
- [Armbian Firstboot Config](https://docs.armbian.com/User-Guide_Autoconfig/)
- [Armbian Image](https://armbian.com/boards/bigtreetech-cb1)
- [Cartographer 3D](https://docs.cartographer3d.com/)
- [Sonar](https://github.com/mainsail-crew/sonar)

## Settings

- Voron 2.4R2
    - IP Address: `192.168.68.64`
    - Mad Address: `de:84:03:e8:cd:cf`
- Octopus Pro: `1e691b91fae3`
- EBB: `747323232eb7`
- Cartographer: `14c8757f4532`
- Root
    - Username: `root`
    - Password: `password`
- User
    - Name: `Armbian`
    - Username: `armbian`
    - Password: `password`

## Editing File in Linux

1. Run: `sudo vim /path/to/file.txt`
2. Type `:wq` to save and exit.

### Vim Commands

- Force exit with out saving: `:q!`

## Armbian

1. If Armbian firsboot config is not working properly, configure Wi-Fi with `armbian-config`.
2. Update and install dependencies with `sudo apt update` then `sudo apt install git vim python3-serial`.
3. Install Klipper with KIAUH.
    - Also install NetworkManager.
4. Update Netplan to use NetworkManager for Wi-Fi.
    - Add NetworkManager as a renderer in file `/etc/netplan/armbian.yaml`:
        ```
        network:
        version: 2
        renderer: networkd
        wifis:
            wlan1:
            renderer: NetworkManager
            dhcp4: true
            dhcp6: true
            macaddress: "de:84:03:e8:cd:cf"
            access-points:
                "May":
                auth:
                    key-management: "psk"
                    password: "0892335770"
        ```
5. Set up CAN bus in networkd:
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

    - Restart networkd: `sudo systemctl restart systemd-networkd`
    - Check networkd status: `sudo systemctl status systemd-networkd`
    - Check queue length: `ip link show can0`, continue below if qlen is not 128.
    - Add settings below to file `/etc/udev/rules.d/99-canbus.rules`:

        ```
        # Set tx queue size for CAN bus.
        SUBSYSTEM=="net", ACTION=="add|change", KERNEL=="can0" ATTR{tx_queue_len}="128"
        ```

    - Reboot

## Katapult & Klipper

- To configure: `make menuconfig`
- To make: `make`
- Output files will be in `~/<katapult/klipper>/out` folder.
- Stop Kliper before flashing firmware and start again after.

### Octopus Pro

1. Enter Octopus Pro DFU mode using CAN bus:

    ```
    ~/klippy-env/bin/python ~/katapult/scripts/flashtool.py -i can0 -f octopus_klipper.bin -u 1e691b91fae3 -r
    ```

2. Flash Klipper:

    ```
    ~/klippy-env/bin/python ~/katapult/scripts/flashtool.py -f octopus_klipper.bin -d <serial/device/path>
    ```

    Sometimes, serial device path can be seen from the result of step 1.

3. You can also flash Katapult using make itself:

    ```
    sudo make flash FLASH_DEVICE=0483:df11
    ```

    Look for flash device using `lsusb`.

### EBB

```
~/klippy-env/bin/python ~/katapult/scripts/flash_can.py -i can0 -f ebb_klipper.bin -u 747323232eb7
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
- Start Klipper: `sudo service klipper start`
- Stop Klipper: `sudo service klipper stop`

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
    2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97
    ```
