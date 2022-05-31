#!/bin/bash 
DATE=$(date)
CONTROL_CHECK="Debian binary package"
UPLOAD_PATH=/var/www/upload/
REPO_PATH=/var/www/repo/
JETSON_VERSION='video-system-run'
STATUS='302 Found'

trap "rm -rf /var/www/repo/*.deb; rm -rf /tmp/*.zip" EXIT

get_artifacts () {
   for V in $JETSON_VERSION
   do
     local JETSON_LATEST_VERSION=$(curl -s  http://web-lab/bortnik/$V/-/jobs/artifacts/devops/download?job=build-job |md5sum | cut -d ' ' -f 1)
     local JETSON_CURRENT_VERSION=$(cat /var/www/repo/$V)
     local GET_STATUS=$(curl -s  -I http://web-lab/bortnik/$V/-/jobs/artifacts/devops/download?job=build-job | grep -oP "302 Found")

         if [[ $JETSON_LATEST_VERSION != $JETSON_CURRENT_VERSION && $STATUS == $GET_STATUS ]]; then
            echo "$JETSON_LATEST_VERSION" | tee /var/www/repo/$V
            logger -i -t SCAN_DEB2 -p local0.info  "$DATE Found a new $V  artifact"
            curl  -L --output /tmp/$V http://web-lab/bortnik/$V/-/jobs/artifacts/devops/download?job=build-job
            cd $REPO_PATH
            unzip -o /tmp/$V
            rm rf /tmp/$V
            RESULT=$(find $REPO_PATH -maxdepth  1 -type f -iname "*.deb*" ! -size 0 | awk -F "/" '{print $NF}')
              for i in $RESULT
                 do
                 CHECK=$(file ${REPO_PATH}${i} | cut -d ' ' -f 2,3,4 )
                     if [[ ${CONTROL_CHECK} != ${CHECK} ]];then
                     logger -i -t SCAN_DEB2 -p local0.info  "in upload was found non a Debian type of package. Only Debian package are allow and unknown will be delete"
                     rm -rf ${i}
              fi
               logger -i -t SCAN_DEB2 -p local0.info "the $i was found in upload directory"
               logger -i -t SCAN_DEB2 -p local0.info "move $i to repository"
               cd $REPO_PATH &&  reprepro -v -S stable -C main includedeb bionic $i &&  rm -f $REPO_PATH$i
              done
            continue
        else
            logger -i -t SCAN_DEB -p local0.info "$DATE Was not found anything new !!!"
            echo "$DATE Was not found anything new !!!"
        fi
  done
}



while true
do

get_artifacts

sleep 60

done
