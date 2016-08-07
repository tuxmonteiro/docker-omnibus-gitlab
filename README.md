Docker Omnibus Gitlab Dev
===

```bash
$ #Example:
$ docker run -it --rm --name my-omnibus-gitlab -v $PWD/var-cache-omnibus:/var/cache/omnibus \
         -v $PWD/tmp:/root/omnibus-gitlab/pkg tuxmonteiro/omnibus-gitlab-mysql /bin/su \
         -l root -c "cd /root/omnibus-gitlab; ./bin/omnibus build gitlab"
```
