#!/bin/sh/
echo "1" | sudo -S xhost +;

docker run -it --rm \
	--privileged=true \
  	--gpus 'all,"capabilities=compute,utility,graphics"' \
  	--shm-size 8G \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v /home/zy2/dataset/zy_temp/dataset/detection/nuscenes/data/can_bus:/root/BEVFormer/data/can_bus \
	-v /home/zy2/dataset/zy_temp/dataset/detection/nuscenes/v1.0-mini:/root/BEVFormer/data/nuscenes \
	-v /home/zy2/perception/BEVFormer:/root/BEVFormer \
	--device=/dev/dri --group-add video  \
	--env="DISPLAY=$DISPLAY" \
	--env="QT_X11_NO_MITSHM=1" \
	-e GDK_SCALE \
  	-e GDK_DPI_SCALE \
	bevformer:1.0  /bin/bash
