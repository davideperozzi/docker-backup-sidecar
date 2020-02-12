# Docker backup sidecar
A very basic backup implementation. Rollback mechanism **not included** (yet).

## Integreation
To use this backup script you can simply include it in your stack like this:

```yml
backup:
  image: davideperozzi/backup-sidecar:latest
  environment:
    AWS_ACCESS_KEY_ID: AWSAccessKeyId
    AWS_SECRET_ACCESS_KEY: AWSSecretAccessKey
    AWS_BUCKET_NAME: backup.bucket.name
    AWS_BUCKET_PATH: /path/inside/bucket # Default: /
```

### Workflow
Inside this image is a folder `/var/out/s3`, which also acts as a `volume`.
Every file inside this folder wil be transferred to the given AWS bucket.

### The backups scripts
There are two folders available, also mounted as volumes: `/opt/scripts/start` and `/opt/scripts/end`.
Each script inside `/opt/scripts/start` will be executed before the upload to S3 and each script
inside the `/opt/scripts/end` will be used after a successful upload to S3.

> Please be aware, that the `/var/out/s3` folder will be cleared after a successful upload

## Controlling the crontab schedule
To change the schedule for the backup crontab you can simply override the following environment variable inside your backup service:

```yml
...
environment:
  CRON_SCHEDULE: '* * * * *' # Run script every minute
```

> Default schedule is `0 0 * * */3,*/6` (twice a week)

## License
See the [LICENSE](./LICENSE) file for license rights and limitations (MIT).