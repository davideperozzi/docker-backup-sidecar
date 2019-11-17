# Docker backup sidecar
A very basic backup implementation, which uses mysqldump, tar and aws-cli to upload relevant data to a bucket. Rollback mechanism **not included** (yet).

## Integreation
To use this backup script you can simply include it in your stack like this:

```yml
database:
  image: mysql/mysql-server:5.7
  ...

backup:
  image: backup_${APP_NAME}:latest
  build: ./packages/backup
  environment:
    DATABASE_HOST: database
    DATABASE_USERNAME: root
    DATABASE_PASSWORD: ************
    AWS_ACCESS_KEY_ID: ******************
    AWS_SECRET_ACCESS_KEY: *********************
    AWS_BUCKET_NAME: the_name_of_the_bucket
    AWS_BUCKET_PATH: /path/inside/bucket # Default: /
  volumes:
    - shared_data:/var/backup/uploads:ro # Make sure it's read-only

volumes:
  shared_data:
```

> Every folder within `/var/backup/` will be included into the archive

## Controlling the crontab schedule
To change the schedule for the backup crontab you can simply override the following environment variable inside your backup service:

```yml
...
environment:
  CRON_SCHEDULE: * * * * * * # Run script every minute
```

> Default schedule is `0 0 * * */3,*/6` (twice a week)

## License
See the [LICENSE](./LICENSE) file for license rights and limitations (MIT).