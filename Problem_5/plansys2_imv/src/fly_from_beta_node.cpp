#include <algorithm>
#include <iostream>
#include <memory>
#include <string>

#include "rclcpp/rclcpp.hpp"
#include "plansys2_executor/ActionExecutorClient.hpp"

class FlyFromBeta : public plansys2::ActionExecutorClient
{
public:
  FlyFromBeta()
  : plansys2::ActionExecutorClient("fly_from_beta", std::chrono::milliseconds(200)),
    progress_(0.0)
  {
  }

private:
  void do_work()
  {
    double increment = 0.2 / 2.0;

    if (progress_ < 1.0) {
      progress_ = std::min(1.0, progress_ + increment);
      send_feedback(progress_, "fly_from_beta running");
    } else {
      finish(true, 1.0, "fly_from_beta completed");
      progress_ = 0.0;
      std::cout << std::endl;
    }

    std::cout << "\r\033[K" << std::flush;
    std::cout << "fly_from_beta ... [" << std::min(100.0, progress_ * 100.0) <<
      "%]  " << std::flush;
  }

  double progress_;
};

int main(int argc, char ** argv)
{
  rclcpp::init(argc, argv);
  auto node = std::make_shared<FlyFromBeta>();
  node->set_parameter(rclcpp::Parameter("action_name", "fly_from_beta"));
  node->trigger_transition(lifecycle_msgs::msg::Transition::TRANSITION_CONFIGURE);
  rclcpp::spin(node->get_node_base_interface());
  rclcpp::shutdown();
  return 0;
}
