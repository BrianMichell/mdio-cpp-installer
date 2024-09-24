# This repo is intended as an example installer
This repo is not intended to maintain parity with the [mdio-cpp](https://github.com/TGSAI/mdio-cpp) repository.
It is largely a workaround for [this](https://github.com/google/tensorstore/issues/190) Tensorstore issue.

# Instructions
1. Clone this repo.
2. Select your installation directory.
3. Select a tag or branch from [mdio-cpp](https://github.com/TGSAI/mdio-cpp/releases)
4. Run the installer. This will generate a lot of output and could take some time.
```bash
$ ./install.sh [install_directory] [mdio_tag]
```

# Linking
NOTE: This may be an incomplete list for linking all components required for **MDIO**.


# Reinstalling
Please remove any **MDIO** artifacts such as cloned repositories or built files from the **MDIO_installer** directory.