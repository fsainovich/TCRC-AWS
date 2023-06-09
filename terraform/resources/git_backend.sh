#!/bin/bash

git config --global credential.helper '!aws codecommit credential-helper $@' && 
git config --global credential.UseHttpPath true 

rm -rf /tmp/backend/

mkdir /tmp/backend/

git clone $1 /tmp/backend/

cp -a ../backend/* /tmp/backend/

cd /tmp/backend/

git add .

git commit -m "First commit"

git push
