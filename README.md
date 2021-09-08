# Working with aptly # 

creating repo:
```
aptly repo create -distribution=bionic -component=main erweka-release
```
adding debian package:
```
aptly repo add erweka-release erweka.dal_1.0.0-preview20200309.2.deb
```

push to repo:
```
aptly publish repo -batch erweka-release s3:erweka.repo:
```

GPG
```
gpg_public.key/gpg_private.key is necessary for signing debian packages. Public key is needed for 
fetching debian package from minio server. Also for fetching from minio it is necessary to have the erweka root ca. 
```