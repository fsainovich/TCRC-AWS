#!/bin/bash

git config --global credential.helper '!aws codecommit credential-helper $@' && 
git config --global credential.UseHttpPath true 

rm -rf /tmp/frontend/

mkdir /tmp/frontend/

git clone $1 /tmp/frontend/

cp -a ../frontend/* /tmp/frontend/

cd /tmp/frontend/

git add .

git commit -m "First commit"

git push
