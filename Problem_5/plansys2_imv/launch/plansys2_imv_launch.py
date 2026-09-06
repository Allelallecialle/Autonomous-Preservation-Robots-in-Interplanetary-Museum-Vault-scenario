import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


ACTION_NAMES = [
    "move_via_tunnel",
    "move_via_tunnel_to_beta",
    "activate_sealing",
    "deactivate_sealing",
    "fly",
    "fly_to_beta",
    "fly_from_beta",
    "pickup_pod",
    "putdown_pod",
    "pickup_artifact",
    "putdown_artifact",
    "secure_in_pod",
    "unload_from_pod",
    "cool",
    "cool_in_pod",
]


def generate_launch_description():
    imv_dir = get_package_share_directory('plansys2_imv')
    namespace = LaunchConfiguration('namespace')

    declare_namespace_cmd = DeclareLaunchArgument(
        'namespace',
        default_value='',
        description='Namespace')

    plansys2_cmd = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(os.path.join(
            get_package_share_directory('plansys2_bringup'),
            'launch',
            'plansys2_bringup_launch_monolithic.py')),
        launch_arguments={
            'model_file': imv_dir + '/pddl/domain.pddl',
            'namespace': namespace
        }.items())

    ld = LaunchDescription()
    ld.add_action(declare_namespace_cmd)
    ld.add_action(plansys2_cmd)

    for action_name in ACTION_NAMES:
        action_cmd = Node(
            package='plansys2_imv',
            executable=f'{action_name}_node',
            name=f'{action_name}_node',
            namespace=namespace,
            output='screen',
        )
        ld.add_action(action_cmd)

    return ld
