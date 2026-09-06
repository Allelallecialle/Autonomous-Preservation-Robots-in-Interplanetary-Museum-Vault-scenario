# Autonomous-Preservation-Robots-in-Interplanetary-Museum-Vault-scenario
Final Project for the Automated Planning Theory and Practice course



## Problem 5
'''
cd /computer/Final_project/Autonomous-Preservation-Robots-in-Interplanetary-Museum-Vault-scenario/Problem_5

source /opt/ros/humble/setup.bash

cd plansys2_imv

colcon build --symlink-install --packages-select plansys2_imv

source install/setup.bash

ros2 launch plansys2_imv plansys2_imv_launch.py
'''

Open another terminal:
'''
docker ps -> obtain <CONTAINER_ID>

docker exec -it <CONTAINER_ID> bash

source /opt/ros/humble/setup.bash

cd /computer/Final_project/Autonomous-Preservation-Robots-in-Interplanetary-Museum-Vault-scenario/Problem_5/plansys2_imv

source install/setup.bash
```

Ensure to be in plansys2_imv folder, then:
```
ros2 run plansys2_terminal plansys2_terminal --ros-args -p problem_file:=$(pwd)/pddl/problem.pddl
```

Once the console prompt (`>`) appears, just type:
```
get plan
run
```


Useful to run after building or if there are issues:
```
# kill everything, don't rely on Ctrl+C alone
pkill -9 -f plansys2
pkill -9 -f _node
ros2 daemon stop
ros2 daemon start
```