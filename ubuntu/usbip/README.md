# Usbip

How to install usbip to ubuntu

Most likely you already have `usbip` installed. You can verify it just checking if command `usbip` returns anything

We need to load `vhci_hcd` module to be able to attach usb devices.

To automatically load the module on boot create a new file with given content:

`echo vhci_hcd | sudo tee /etc/modules-load.d/vhci_hcd.conf`

To manually load the module:

`sudo modprobe vhci_hcd`
