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
- [RVTools](https://www.robware.net/rvtools/) Installer file (tested with `v4.2.2`, search for `RVTools4.2.2.msi` on Google)

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

- Create a copy of `.env.template` to `.env` and modify the file so the variables match with your environment:

```shell
cp .env.template .env
vi .env
```

- Source the file to "load" the variables on your system:

```shell
source .env
```

- If you have Docker installed you just have to type the following commands and wait approximately **15 minutes** for the program to run completely (after building the image).

```shell
# Build Docker image
docker build -t cpt/rvtools-wine .
# Run the image inside a container
docker run -d --rm cpt/rvtools-wine
```

## Authors & Credit
* scottyhardy (creator of the image that NyaMisty based his image on, source : https://github.com/scottyhardy/docker-wine)
* NyaMisty (creator of the image with DotNET integrated I based this project on, source: https://github.com/NyaMisty/docker-wine-dotnet & https://hub.docker.com/r/nyamisty/docker-wine-dotnet)
* GERARD Angelo
