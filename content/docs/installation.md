# Installation

## Docker

The simplest way to run Flipt is via Docker. This streamlines the installation and configuration by using a reliable runtime.

### Prerequisites

Docker installation is required on the host, see the [official installation docs](https://docs.docker.com/install/).

### Run the image

```shell
docker run -d \
    -p 8080:8080 \
    -p 9000:9000 \
    -v $HOME/flipt:/var/opt/flipt \
    markphelps/flipt:latest
```

This will download the image and start a Flipt container and publish ports needed to access the UI and backend server. All persistent Flipt data will be stored in `$HOME/flipt`.

{{< hint info >}}
`$HOME/flipt` is just used as an example, you can use any directory you would like on the host.
{{< /hint >}}

The Flipt container uses host mounted volumes to persist data:

| Host location | Container location | Purpose |
|---|---|---|
| $HOME/flipt  | /var/opt/flipt | For storing application data |

This allows data to persist between Docker container restarts.

{{< hint warning >}}
If you don't use mounted volumes to persist your data, your data will be lost when the container exits!
{{< /hint >}}

After starting the container you can visit [http://0.0.0.0:8080](http://0.0.0.0:8080) to view the application.

{{< hint info >}}
Flipt runs without root in the Docker container as of [v1.6.1](https://github.com/markphelps/flipt/releases/tag/v1.6.1).
{{< /hint >}}

## Download from GitHub

You can always download the latest release archive of Flipt from the [Releases](https://github.com/markphelps/flipt/releases) section on GitHub.

Download to an accessible location on your host and un-zip with the following commands (requires [jq](https://stedolan.github.io/jq/)):

```shell
$ export FLIPT_VERSION=$(curl --silent "https://api.github.com/repos/markphelps/flipt/releases/latest" | jq '.tag_name?' | tr -d '"' | tr -d 'v')
$ curl -L "https://github.com/markphelps/flipt/releases/download/v${FLIPT_VERSION}/flipt_${FLIPT_VERSION}_linux_x86_64.tar.gz" -o flipt.tar.gz && \
    tar -xvf flipt.tar.gz && \
    chmod +x ./flipt
```

This archive contains the Flipt binary, configuration, database migrations, README, LICENSE, and CHANGELOG files.

{{< hint info >}}
You will need to update the config file: `default.yml` if your migrations and database locations differ from the standard locations.
{{< /hint >}}

Run the Flipt binary with:

```shell
./flipt --config PATH_TO_YOUR_CONFIG
```

See the [Configuration]({{< relref "/docs/configuration" >}}) section for more details.
