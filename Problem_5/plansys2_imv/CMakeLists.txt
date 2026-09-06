cmake_minimum_required(VERSION 3.8)
project(plansys2_imv)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(rclcpp_lifecycle REQUIRED)
find_package(plansys2_msgs REQUIRED)
find_package(plansys2_domain_expert REQUIRED)
find_package(plansys2_executor REQUIRED)
find_package(plansys2_planner REQUIRED)
find_package(plansys2_problem_expert REQUIRED)
find_package(plansys2_bringup REQUIRED)

set(dependencies
  rclcpp
  rclcpp_lifecycle
  plansys2_msgs
  plansys2_domain_expert
  plansys2_executor
  plansys2_planner
  plansys2_problem_expert
  plansys2_bringup
)

set(action_names
  move_via_tunnel
  move_via_tunnel_to_beta
  activate_sealing
  deactivate_sealing
  fly
  fly_to_beta
  fly_from_beta
  pickup_pod
  putdown_pod
  pickup_artifact
  putdown_artifact
  secure_in_pod
  unload_from_pod
  cool
  cool_in_pod
)

foreach(action_name ${action_names})
  add_executable(${action_name}_node src/${action_name}_node.cpp)
  ament_target_dependencies(${action_name}_node ${dependencies})
  install(TARGETS ${action_name}_node DESTINATION lib/${PROJECT_NAME})
endforeach()

install(DIRECTORY
  launch
  pddl
  init
  DESTINATION share/${PROJECT_NAME}
)

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()
