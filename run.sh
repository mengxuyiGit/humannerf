#!/bin/bash

HUMAN_ID='377'

# render images
output=$(python run.py --type freeview --cfg configs/human_nerf/zju_mocap/${HUMAN_ID}/adventure.yaml)

images_dir1=$(echo "$output" | grep "RUN_SAVED_DIR:" | awk '{print $2}')
echo "The value of my_var1 from the Python script is: $images_dir1"

# process transformations
python run_transformation.py "$images_dir1"

# rename the whole dir
replaced_dir1=${images_dir1/_0/_wbkg_230}_p${HUMAN_ID}
echo "Rename $images_dir1 to $replaced_dir1 "
if [ ! -d "$replaced_dir1" ]; then
    # If the directory does not exist, do nothing
    :
else
    echo "Directory '$replaced_dir1' already exists, delete it first"
    rm -r $replaced_dir1
fi
mv $images_dir1 $replaced_dir1

# cp the dir to Data
data_dir=/data/xymeng/Data/fyp/ZJU_MOCAP/p${HUMAN_ID}
# Check if the directory exists
if [ ! -d "$data_dir" ]; then
    # If the directory does not exist, create it
    mkdir "$data_dir"
    echo "Directory '$data_dir' created."
else
    echo "Directory '$data_dir' already exists."
fi
echo "Copy $replaced_dir1 to $data_dir"
cp -r $replaced_dir1 ${data_dir}/

## cd to mobilenerf dir and execute 
MOBILE_DIR=/data/xymeng/Repo/jax3d/jax3d/projects/mobilenerf/
cd $MOBILE_DIR
pwd
EXP_SUFFIX='_thu'
OBJ_NAME=$(basename "$replaced_dir1")
SCENE_DIR=/data/xymeng/Data/fyp/ZJU_MOCAP/p${HUMAN_ID}/
file_list=("stage1.py" "stage2.py" "stage3.py")
# Execute the scripts sequentially in a for loop
for script in "${file_list[@]}"; do
    echo "Running $script"
    python $script --exp_suffix ${EXP_SUFFIX} --object_name ${OBJ_NAME} --scene_base ${SCENE_DIR}
    echo "$script completed"
done
echo "Everying about human id ${HUMAN_ID} is done!"
# python stage1.py --exp_suffix ${EXP_SUFFIX} --object_name ${OBJ_NAME} --scene_dir ${SCENE_DIR}\
# && python stage2.py && python stage3.py