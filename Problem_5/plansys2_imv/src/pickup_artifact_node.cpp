#include <algorithm>
#include <iostream>
#include <memory>
#include <string>

#include "rclcpp/rclcpp.hpp"
#include "plansys2_executor/ActionExecutorClient.hpp"

class PickupArtifact : public plansys2::ActionExecutorClient
{
public:
  PickupArtifact()
  : plansys2::ActionExecutorClient("pickup_artifact", std::chrono::milliseconds(200)),
    progress_(0.0)
  {
  }

private:
  void do_work()
  {
    double increment = 0.2 / 1.0;

    if (progress_ < 1.0) {
      progress_ = std::min(1.0, progress_ + increment);
      send_feedback(progress_, "pickup_artifact running");
    } else {
      finish(true, 1.0, "pickup_artifact completed");
      progress_ = 0.0;
      std::cout << std::endl;
    }

    std::cout << "\r\033[K" << std::flush;
    std::cout << "pickup_artifact ... [" << std::min(100.0, progress_ * 100.0) <<
      "%]  " << std::flush;
  }

  double progress_;
};

int main(int argc, char ** argv)
{
  rclcpp::init(argc, argv);
  auto node = std::make_shared<PickupArtifact>();
  node->set_parameter(rclcpp::Parameter("action_name", "pickup_artifact"));
  node->trigger_transition(lifecycle_msgs::msg::Transition::TRANSITION_CONFIGURE);
  rclcpp::spin(node->get_node_base_interface());
  rclcpp::shutdown();
  return 0;
}
