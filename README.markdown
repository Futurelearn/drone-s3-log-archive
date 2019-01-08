# drone-s3-log-archive

Largely yoinked from https://github.com/FutureLearn/drone-s3-bash-cache

A small drone plugin intended to upload a tarball of log and other items
of debug use to S3 for investigating failing builds.

## Usage

```yaml
upload logs:
  image: FutureLearn/drone-s3-log-archive
  pull: true
  bucket: futurelearn-artefacts
  folder: drone/builds
  upload:
    - log
    - tmp/capybara
```

## Docker

To build, run:

`docker build --rm -t futurelearn/drone-s3-log-archive .`

