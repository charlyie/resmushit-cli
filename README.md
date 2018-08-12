# reSmush.it Image Optimizer CLI client

CLI client for the **reSmush.it Image Optimization API**

## What is reSmush.it ?

Use reSmush.it Image Optimizer for **FREE** to **optimize your pictures file sizes**. Improve your performances by using reSmush.it, the 3 billion images API optimizer.

reSmush.it Image Optimizer allow to use **free Image optimization** based on [reSmush.it API](https://resmush.it/ "Image Optimization API, developped by Charles Bourgeaux"). reSmush.it provides image size reduction based on several advanced algorithms. The API accept JPG, PNG and GIF files up to **5MB**.

## What is this tool ?

This tool allow you to perform a powerful optimization of one or multiple pictures using a bash (command line) script based on the reSmush.it API.

## Getting Started

This tool can optimize on or several pictures. The recursive option is not yet implemented

1. Download the tool using a git clone command on your computer/server
2. Make the file `resmushit-cli.sh` executable using the following command : `chmod +x resmushit-cli.sh`
3. Run the optimizer by typing command `./resmushit-cli.sh myfile.jpg`

### Prerequisites

This will require to be executed on a Linux based Operating System (Linux or MacOS). The following packages must be installed on the system

- `curl`
- `jq` (*see [jq Homepage](https://stedolan.github.io/jq/ "jq is a lightweight and flexible command-line JSON processor.")*)

### Install on my system

If you're using a Linux system (Debian, CentOS...) you can install after cloning from the GIT repo by typing the following command as `root` user (or using `sudo`) :

- `mv resmushit-cli.sh /usr/bin/resmushit;chmod +x /usr/bin/resmushit`

Your CLI optimizer will be available everywhere in your server/computer by typing `resmushit`




### Options
- `-h` or `--help` : display the help menu
- `-v` or `--version` : display the current version of reSmushit CLI client
- `-q <quality>` or `--quality <quality>` : specify the quality factor between 0 and 100 (default is 92).
- `-o <directory>` or `--output <directory>` : specify an output directory (will be created if not present) 
- `--notime` : avoid to display timer in output
- `--quiet` : run in quiet mode

## Roadmap
- [ ] Add EXIF preservation option
- [ ] Add progress bar mode
- [ ] Add support of recursive optimization
- [ ] Add an installer mode
- [ ] Add an auto-update method based on Git repo

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/charlyie/resmushit-wordpress). 

## Authors

* **Charles Bourgeaux** - *Initial work* - [reSmush.it](https://resmush.it)


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Support on Beerpay
Hey dude! Help me out for a couple of :beers:!

[![Beerpay](https://beerpay.io/charlyie/resmushit-wordpress/badge.svg?style=beer-square)](https://beerpay.io/charlyie/resmushit-wordpress)  [![Beerpay](https://beerpay.io/charlyie/resmushit-wordpress/make-wish.svg?style=flat-square)](https://beerpay.io/charlyie/resmushit-wordpress?focus=wish)
