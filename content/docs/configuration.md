# Configuration

There are two ways to configure Flipt: using a configuration file or through environment variables.

## Configuration File

The default way that Flipt is configured is with the use of a configuration file [default.yml](https://github.com/markphelps/flipt/blob/master/config/default.yml).

This file is read when Flipt starts up and configures several important properties for the server.

You can edit any of these properties to your liking, and on restart Flipt will pick up the new changes.

{{< hint info >}}
These defaults are commented out in [default.yml](https://github.com/markphelps/flipt/blob/master/config/default.yml) to give you an idea of what they are. To change them you'll first need to uncomment them.
{{< /hint >}}

These properties are as follows:

| Property                         | Description                                                                        | Default                      | Since   |
|----------------------------------|------------------------------------------------------------------------------------|------------------------------|---------|
| `log.level`                      | Level at which messages are logged (trace, debug, info, warn, error, fatal, panic) | info                         |         |
| `log.file`                       | File to log to instead of STDOUT                                                   |                              | v0.10.0 |
| `ui.enabled`                     | Enable UI and API docs                                                             | true                         |         |
| `cors.enabled`                   | Enable CORS support                                                                | false                        | v0.7.0  |
| `cors.allowed_origins`           | Sets Access-Control-Allow-Origin header on server                                  | "*" (all domains)            | v0.7.0  |
| `cache.memory.enabled`           | Enable in-memory caching                                                           | false                        |         |
| `cache.memory.expiration`        | Duration at which cache items are considered expired                               | -1 (none)                    | v0.12.0 |
| `cache.memory.eviction_interval` | Interval at which expired items are evicted from the cache                         | 10m (10 minutes)             | v0.12.0 |
| `server.protocol`                | `http` or `https`                                                                  | http                         | v0.8.0  |
| `server.host`                    | The host address on which to serve the Flipt application                           | 0.0.0.0                      |         |
| `server.http_port`               | The HTTP port on which to serve the Flipt REST API and UI                          | 8080                         |         |
| `server.https_port`              | The HTTPS port on which to serve the Flipt REST API and UI                         | 443                          | v0.8.0  |
| `server.grpc_port`               | The port on which to serve the Flipt GRPC server                                   | 9000                         |         |
| `server.cert_file`               | Path to the certificate file (if protocol is set to `https`)                       |                              | v0.8.0  |
| `server.cert_key`                | Path to the certificate key file (if protocol is set to `https`)                   |                              | v0.8.0  |
| `db.url`                         | URL to access Flipt database                                                       | file:/var/opt/flipt/flipt.db |         |
| `db.max_idle_conn`               | The maximum number of connections in the idle connection pool                      | 2                            | v0.17.0 |
| `db.max_open_conn`               | The maximum number of open connections to the database                             | unlimited                    | v0.17.0 |
| `db.conn_max_lifetime`           | Sets the maximum amount of time in which a connection can be reused                | unlimited                    | v0.17.0 |
| `db.migrations.path`             | Where the Flipt database migration files are kept                                  | /etc/flipt/config/migrations |         |
| `tracing.jaeger.enabled`         | Enable tracing support with Jaeger                                                 | false                        | v0.17.0 |
| `tracing.jaeger.host`            | The UDP host destination to report spans                                           | localhost                    | v0.17.0 |
| `tracing.jaeger.port`            | The UDP port destination to report spans                                           | 6831                         | v0.17.0 |
| `meta.check_for_updates`         | Enable check for newer versions of Flipt on startup                                | true                         | v0.17.0 |

## Environment Variables

All options in the configuration file can be overridden using environment variables using the syntax:

```shell
FLIPT_<SectionName>_<KeyName>
```

{{< hint info >}}
Using environment variables to override defaults is especially helpful when running with Docker as described in the [Installation]({{< relref "/docs/installation" >}}) documentation.
{{< /hint >}}

Everything should be upper case, `.` should be replaced by `_`. For example, given these configuration settings:

```yaml
server:
  grpc_port: 9000

db:
  url: file:/var/opt/flipt/flipt.db
```

You can override them using:

```shell
export FLIPT_SERVER_GRPC_PORT=9001
export FLIPT_DB_URL="postgres://postgres@localhost:5432/flipt?sslmode=disable"
```

## Databases

Flipt supports [SQLite](https://www.sqlite.org/index.html), [Postgres](https://www.postgresql.org/) and [MySQL](https://dev.mysql.com/) databases as of `v0.16.0`.

SQLite is enabled by default for simplicity, however you should use Postgres or MySQL if you intend to run multiple copies of Flipt in a high availability configuration.

The database connection can be configured as follows:

### SQLite

```yaml
db:
  # file: informs flipt to use SQLite
  url: file:/var/opt/flipt/flipt.db
```

### Postgres

```yaml
db:
  url: postgres://postgres@localhost:5432/flipt?sslmode=disable
```

{{< hint info >}}
The Postgres database must exist and be up and running before Flipt will be able to connect to it.
{{< /hint >}}

### MySQL

```yaml
db:
  url: mysql://mysql@localhost:3306/flipt
```

{{< hint info >}}
The MySQL database must exist and be up and running before Flipt will be able to connect to it.
{{< /hint >}}

### Migrations

From time to time the Flipt database must be updated with new schema. To accomplish this, Flipt includes a `migrate` command that will run any pending database migrations for you.

If Flipt is started and there are pending migrations, you will see the following error in the console:

```bash
migrations pending, please backup your database and run `flipt migrate`
```

If it is your first run of Flipt, all migrations will automatically be run before starting the Flipt server.

{{< hint danger >}}
You should backup your database before running `flipt migrate` to ensure that no data is lost if an error occurs during migration.
{{< /hint >}}

If running Flipt via Docker, you can run the migrations in a separate container before starting Flipt by running:

```bash
docker run -it markphelps/flipt:latest /bin/sh -c './flipt migrate'
```

## Import/Export

Flipt supports importing and exporting your feature flag data since [v0.13.0](https://github.com/markphelps/flipt/releases/tag/v0.13.0).

### Import

To import previously exported Flipt data, use the `flipt import` command. You can import either from a file or from STDIN.

To import from STDIN, Flipt requires the `--stdin` flag:

```bash
cat flipt.yaml | flipt import --stdin
```

If not importing using `--stdin`, Flipt requires the file to be imported as an argument:

```bash
flipt import flipt.yaml
```

This command supports the `--drop` flag that will drop all of the data in your Flipt database tables before importing. This is to ensure that no data collisions occur during the import.

{{< hint danger >}}
Be careful when using the `--drop` flag as it will immediately drop all of your data and there is no undo. It is recommend to first backup you database before running this command just to be safe.
{{< /hint >}}

### Export

To export Flipt data, use the `flipt export` command.

By default, `export` will output to STDOUT:

```bash
$ flipt export

flags:
- key: new-contact-page
  name: New Contact Page
  description: Show users our Beta contact page
  enabled: true
  variants:
  - key: blue
    name: Blue
  - key: green
    name: Green
```

You can also export to a file using the `-o filename` or `--output filename` flags:

```bash
flipt export -o flipt.yaml
```

## Caching

Flipt supports an in-memory cache to enable faster reads and evaluations. Enabling in-memory cache has been shown to speed up read performance by several orders of magnitude.

{{< hint warning >}}
Enabling in-memory caching when running more that one instance of Flipt is not advised as it may lead to unpredictable results.
{{< /hint >}}

Caching works as follows:

* All reads go through the cache
* All writes flush the **entire cache** to ensure the cache is kept up to date
* A cache miss will fetch the item from the database and add the item to the cache for the next read
* A cache hit will simply return the item from the cache, not interacting with the database

To enable caching set the following in your config:

```yaml
cache:
  memory:
    enabled: true
```

### Expiration/Eviction

You can also configure an optional duration at which items in the cache are marked as expired.

For example, if you set the cache expiration to `5m`, items that have been in the cache for longer than 5 minutes will be marked as expired, meaning the next read for that item will hit the database.

Setting an eviction interval will automatically remove expired items from your cache at a defined period.

{{< hint info >}}
The combination of cache expiration and eviction can help lessen the amount of memory your cache uses, as infrequently accessed items will be removed over time.
{{< /hint >}}

To tune the expiration and eviction interval of the cache set the following in your config:

```yaml
cache:
  memory:
    enabled: true
    expiration: 5m # items older than 5 minutes will be marked as expired
    eviction_interval: 2m # expired items will be evicted from the cache every 2 minutes
```

## Metrics

Flipt exposes [Prometheus](https://prometheus.io/) metrics at the `/metrics` HTTP endpoint. To see which metrics are currently supported, point your browser to `FLIPT_HOST/metrics` (ex: `localhost:8080/metrics`).

You should see a bunch of metrics being recorded such as:

```text
flipt_cache_hit_total{cache="memory",type="flag"} 1
flipt_cache_miss_total{cache="memory",type="flag"} 1
...
go_gc_duration_seconds{quantile="0"} 8.641e-06
go_gc_duration_seconds{quantile="0.25"} 2.499e-05
go_gc_duration_seconds{quantile="0.5"} 3.5359e-05
go_gc_duration_seconds{quantile="0.75"} 6.6594e-05
go_gc_duration_seconds{quantile="1"} 0.00026651
go_gc_duration_seconds_sum 0.000402094
go_gc_duration_seconds_count 5
...
```

There is an [example](https://github.com/markphelps/flipt/tree/master/examples/prometheus) provided in the GitHub repository showing how to setup Flipt with Prometheus.

## Tracing

Flipt supports distributed tracing via the [OpenTracing](https://opentracing.io/) protocol and [Jaeger](https://www.jaegertracing.io/) library. Enable tracing via the configuration values described above and point Flipt to your Jaeger host to record spans.

## Authentication

There is currently no built in authentication, authorization or encryption as Flipt was designed to work inside your trusted architecture and not be exposed publicly. If you wish to expose the Flipt dashboard and REST API publicly using HTTP Basic Authentication, you can do so by using a reverse proxy.

There is an [example](https://github.com/markphelps/flipt/tree/master/examples/auth) provided in the GitHub repository showing how this can work.
