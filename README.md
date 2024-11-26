<p align="center">
  <img src="img/rvtwine.png">
</p>

# RVTools mailer on Wine - Docker image
This project sends [RVTools](https://www.robware.net/rvtools/) file exported from your VMware infrastructure by mail using [Wine](https://www.winehq.org/) and [Docker](https://www.docker.com/)

## Screenshot
*Coming soon*

## Features
- [x] Sends `.xlsx` file exported from RVTools to a mail address of your choice
- [x] Only needs Docker to work, everything else is automated!
- [ ] *More coming soon...*

## Installation
Please make sure you have the following prerequisites:

- [Git](https://git-scm.com/downloads)
- [Docker](https://www.docker.com/)
- SMTP mail server
- [RVTools](https://www.robware.net/rvtools/) Installer file (tested with [`v4.2.2`](https://archive.org/details/rvtools-4.2.2))
<details>
<summary>Show details for RVTools</summary>

```
Name: RVTools 4.2.2
File name: RVTools4.2.2.msi
File Size: 6.7 MB
SHA-256 Checksum: bb947325f9b58b715bcb5dd761ec8156b01d0fa07f4a0baeefa0ed75779bdc41
Published: 2021-12-29
```

</details>


### Downloading the source code
Clone the repository:

```shell
git clone https://github.com/canalplustelecom/rvtools-wine.git
cd rvtools-wine
```

To update the source code to the latest commit, run the following command inside the `rvtools-wine` directory:

```shell
git pull
```

## Usage

- Add the installer file `RVTools4.2.2.msi` inside project's folder.

- Create a copy of `.env.sh.template` to `.env.sh` and modify the file so the variables match with your environment:

```shell
cp .env.sh.template .env.sh
vi .env.sh
```

- Create a copy of `.message.txt.template` to `.message.txt` and modify the file with the message you want to send (supports environment variables):

```shell
cp .message.txt.template .message.txt
vi .message.txt
```

- If you have Docker installed you just have to type the following commands and wait approximately **15 minutes** for the program to run completely (after building the image).

```shell
# Build Docker image
docker build -t cpt/rvtools-wine .
# Run the image inside a container
docker run -d --rm cpt/rvtools-wine
```

## Example
A typical usage could be to run the command above each week with `crontab`:

```shell
# Edit your cron tasks
crontab -e
# Add the project's command to this file and whatever else you want
54 1 * * 2 docker run -d --rm cpt/rvtools-wine >> /var/log/rvtools-wine.log 2>&1
@weekly date >> /var/log/beforereboot.log && /sbin/shutdown -r +5
```

## Troubleshooting
The following command can help you troubleshoot the image (you also have to modify `rvt-gen-script.sh` to strip `xvfb-run` so RVTools window shows on your display):
```shell
docker run --net host -e DISPLAY=${DISPLAY} --rm -it -v /tmp/.X11-unix:/tmp/.X11-unix:rw --entrypoint /bin/bash cpt/rvtools-wine
```
Non-exhaustive list of errors you can safely ignore in console:
```
log4net:ERROR Failed to find configuration section 'log4net' in the application's .config file. Check your .config file for the <log4net> and <configSections> elements. The configuration section should look like: <section name="log4net" type="log4net.Config.Log4NetConfigurationSectionHandler,log4net" />
```
And:
```
X connection to :99 broken (explicit kill or server shutdown).
```

## Authors & Credit
* scottyhardy (creator of the image that NyaMisty based his image on, source: https://github.com/scottyhardy/docker-wine)
* NyaMisty (creator of the image with DotNET integrated I based this project on, source: https://github.com/NyaMisty/docker-wine-dotnet & https://hub.docker.com/r/nyamisty/docker-wine-dotnet)
* GERARD Angelo
