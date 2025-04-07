# How to setup FIDO2 key with Yubikey

## Add FIDO2 key into Yubikey

Choose one of the factors below

Factors                                          | Description                                                                                      | Command
------------------------------------------------ | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------
No PIN or touch are required                     | You will not be required to enter your FIDO2 PIN or touch your YubiKey each time to authenticate | `ssh-keygen -t ed25519-sk -O resident -O no-touch-required`
PIN but no touch required                        | Entering the PIN will be required but touching the physical key will not                         | `ssh-keygen -t ed25519-sk -O resident -O verify-required -O no-touch-required`
No PIN but touch is required                     | You will only need to touch the YubiKey to authenticate                                          | `ssh-keygen -t ed25519-sk -O resident`
A PIN and a touch are required (**most secure**) | This is the most secure option, it requires both the PIN and touching to be used                 | `ssh-keygen -t ed25519-sk -O resident -O verify-required`

Remember to add `-O application=ssh:<your-choice-here>`. This allows you to add multiple keys into Yubikey.
We can finalize the command with a comment by adding `-C "<your comment>"`

So, final command could look like this:
`ssh-keygen -t ed25519-sk -O resident -O verify-required -O application=ssh:hetzner -C "Yubikey 5C NFC Hetzner"`

## Export keys from Yubikey

Use command `ssh-keygen -K`

Remember to rename key to format `id_ed25519_sk` on Windows for it to work.

## Create config file

If you have multiple ssh keys, you can create a config file and define multiple keys to be used for a single connection

Go to `~/.ssh` folder and create a file `config` without any extension

For each connection add following section

```bash
Host <connection-name> wombat-1.sleepingwombat.com
    HostName wombat-1.sleepingwombat.com
    IdentityFile ~/.ssh/<private-key>
    IdentityFile ~/.ssh/<another-private-key>
    User <username>
    IdentityOnly yes
```

Example

```bash
Host wombat-1 wombat-1.sleepingwombat.com
    HostName wombat-1.sleepingwombat.com
    IdentityFile ~/.ssh/id_ed25519_sk_rk_hetzner_yubikey_5_nfc
    IdentityFile ~/.ssh/id_ed25519_sk_rk_hetzner_yubikey_5c_nfc
    User wombat
    IdentityOnly yes
```

## Use key on Putty CAC

First import keys by going to `Connection` -> `SSH` -> `Certificate` -> `FIDO Tools` -> `Import keys`

Then choose FIDO key by going to `Connection` -> `SSH` -> `Certificate` -> `Set FIDO Key`
