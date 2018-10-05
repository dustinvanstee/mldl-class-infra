#!/bin/bash
BDIR=/data/mldl-class-infra/powerai4.0
DKR_REPO=mldl-powerai4.0

cd $BDIR
sudo docker build $BDIR -t $DKR_REPO

# Rename a docker image
docker tag $DKR_REPO:latest dustinvanstee/$DKR_REPO:latest
# docker save dustinvanstee/mldl-2018 > mldl-2018.tar

sudo docker login --username=dustinvanstee --email=dustinvanstee@gmail.com --password=n1mb1x
docker push dustinvanstee/$DKR_REPO

# Jarvice ! -> https://jarvice.readthedocs.io/en/latest/api/#jarvicehistory
jarvice_endpoint_url="https://api.jarvice.com/jarvice/pull"
#jarvice_user_username=vanstee
#jarvice_user_apikey=0cff0e2fe32549faa3ef7cf271535a5fce12fdd8
jarvice_user_username=poweraiclassleader
jarvice_user_apikey=581e37846a9f45a4bdcfa23046aa7e9cda332f9a

jarvice_app_id=`echo $DKR_REPO | sed -e "s/-/_/"`
jarvice_job_name="auto pull"
jarvice_docker_repo="$DKR_REPO"

# 
echo "The following needs to be already created .... "
echo "Docker repo = $DKR_REPO"
echo "Jarvice App Name = $jarvice_app_id"
echo "jarvice_user_username=$jarvice_user_username"


# Bang! Pull onnly 
curl --get "${jarvice_endpoint_url}"  --data-urlencode "username=${jarvice_user_username}" --data-urlencode "apikey=${jarvice_user_apikey}" --data-urlencode "target=${jarvice_app_id}" --data-urlencode "repo=${jarvice_docker_repo}" 

