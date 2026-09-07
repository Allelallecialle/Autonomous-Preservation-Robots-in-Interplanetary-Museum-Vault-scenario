# Autonomous-Preservation-Robots-in-Interplanetary-Museum-Vault-scenario
Final Project for the Automated Planning Theory and Practice course.

The Interplanetary Museum Vault (IMV) scenario is a subterranean Martian
research outpost where robotic curators relocate artifacts of different types (fragile,
temperature sensitive, core samples) to their appropriate destinations 
under environmental constraints (sealed tunnel crossings, periodically
seismic unstable Hall β). The assignment is solved incrementally across
five subproblems, each in its own folder, following the indications in `Assignment.pdf`.
See `Automated_planning_report.pdf` for in detail description of
the modelling choices and results per problem.


## Repository structure
 
```
.
├── Problem_1/                  Classical planning (LAMA-first, FF, FD A*/LM-cut)
├── Problem_2/                  Multi-agent + capacity; same planners as Problem 1
├── Problem_3/                  HTN (Panda)
├── Problem_4/                  Durative actions (OPTIC, POPF, TFD) + seismic variant
├── Problem_5/
│   └── plansys2_imv/           ROS2/PlanSys2 package
├── Automated_planning_report.pdf
└── README.md
```

## Problem 1 — Classical Planning
Single robotic curator, no concurrency, no capacity limits. Solved with
three classical planners via `planutils`, compared for plan
length/quality vs. search cost.


```bash
cd Problem_1

planutils run lama-first domain.pddl problem.pddl
planutils run ff domain.pddl problem.pddl

planutils run fast-downward -- domain.pddl problem.pddl --search "astar(lmcut())"
```

# Validate the plans with VAL
```
planutils run val -- Validate domain.pddl problem.pddl <plan_file>
```

## Problem 2 — Multi-Agent & Optimal Planning
 
Adds a second agent (`drone1`) with different capabilities, and a
per-robot capacity limit via `slot` objects. Same three planners as
Problem 1:
 
```bash
cd Problem_2
planutils run lama-first domain.pddl problem.pddl
planutils run ff domain.pddl problem.pddl
planutils run fast-downward -- domain.pddl problem.pddl --search "astar(lmcut())"
```

## Problem 3 — HTN Planning
 
Same primitive actions as Problem 2. Solved with Panda, the only HTN planner in
`planutils`:
 
```bash
cd Problem_3
planutils run panda domain.pddl problem.pddl
```
 
VAL doesn't accept HTN problems directly. The plan's validity has to be
confirmed by manually inspecting the final state, i.e. goal flags reached.

## Problem 4 — Temporal Planning and Concurrency
 
Converts the domain to `:durative-action`s with a fixed duration table.
Two scenarios: a non-seismic variant (maximizing
parallelism) and a seismic variant. Solved with OPTIC, POPF, and TFD:
 
```bash
cd Problem_4
 
# Non-seismic
planutils run optic domain.pddl problem.pddl
planutils run popf domain.pddl problem.pddl
planutils run tfd domain.pddl problem.pddl
 
# Seismic (TFD not applicable)
planutils run optic domain_seismic.pddl problem_seismic.pddl
planutils run popf domain_seismic.pddl problem_seismic.pddl
```
 
Gantt charts can be generated from the OPTIC plan output with [pddl-gantt](https://github.com/jan-dolejsi/pddl-gantt).



## Problem 5 - PlanSys2 integration
Deploys Problem 4's non-seismic variant inside
PlanSys2/ROS2 Humble, using one fake action-performer node per PDDL
action.

### Terminal 1 — build + launch PlanSys2 and fake action performer nodes
```bash
cd Problem_5/plansys2_imv

source /opt/ros/humble/setup.bash

colcon build --symlink-install --packages-select plansys2_imv

source install/setup.bash

ros2 launch plansys2_imv plansys2_imv_launch.py
```

Wait until the log settles with all four PlanSys2 lifecycle managers
(`domain_expert`, `problem_expert`, `executor`, `planner`) reaching
`active`.
 
### Terminal 2 — load the problem, plan, and run
 
If running inside Docker, open a second shell into the same container:

```bash
docker ps -> obtain <CONTAINER_ID>

docker exec -it <CONTAINER_ID> bash

source /opt/ros/humble/setup.bash

cd Problem_5/plansys2_imv

source install/setup.bash
```

Then from inside `plansys2_imv/`:
```bash
ros2 run plansys2_terminal plansys2_terminal --ros-args -p problem_file:=$(pwd)/pddl/problem.pddl
```

Once the console prompt (`>`) appears:
```bash
get plan
run
```


### Useful to run after building or if there are issues:
```bash
# kill everything, don't rely on Ctrl+C alone
pkill -9 -f plansys2
pkill -9 -f _node
ros2 daemon stop
ros2 daemon start
```

## Problem 5 - bonus
Deploys Problem 5 "The Martian" inspired variant.

Run the same commands as above. CHange only the problem file called in Terminal 2:
```bash
ros2 run plansys2_terminal plansys2_terminal --ros-args -p problem_file:=$(pwd)/pddl/problem_bonus.pddl
```