;; ===================================================================
;; Domain: Interplanetary Museum Vault (IMV) - Problem 5
;;
;; Deploys Problem 4 with ROS2 following the PlanSys2 tutorials.
;; 3 changes applied and discussed in the report to adapt it.
;;
;; 1. Flat types only, not hyerarchical (i.e. no `item` supertype for artifact/pod):
;;      (at ?x - item ?l)      -> (at-artifact ?a ?l), (at-pod ?p ?l)
;;      (holding ?s ?x - item) -> (holding-artifact ?s ?a), (holding-pod ?s ?p)
;;
;; 2. PlanSys2's default planner is POPF, so no negative preconditions.
;;    Each is compiled into a complementary positive predicate as in Problem 4.
;;      
;; 3. No parallel actions. PoPF can plan them but two independent fake
;;    action-performer ROS nodes can't run at the same simulated instant the plan assumes.
;;    The PlanSys2's executor detects a violation and cancels both actions, leading
;;    to "Plan Failed". To avoid it: `cool`/`cool_in_pod` is done with the robot
;;    not moving with (`(over all (robot-at ?r ?l))`) added as a 4th parameter.
;; ==========================================================================

(define (domain imv-transport-plansys2)

  (:requirements :strips :typing :durative-actions)

  (:types
    artifact
    pod
    robot
    location
    slot
  )

  (:predicates
    (at-artifact ?a - artifact ?l - location)
    (at-pod ?p - pod ?l - location)
    (robot-at ?r - robot ?l - location)

    (slot-of ?s - slot ?r - robot)
    (slot-free ?s - slot)
    (holding-artifact ?s - slot ?a - artifact)
    (holding-pod ?s - slot ?p - pod)

    (in-pod ?a - artifact ?p - pod)

    (tunnel-connected ?l1 - location ?l2 - location)
    (tunnel-beta-connected ?l1 - location ?l2 - location)
    (is-hall-beta ?l - location)
    (not-hall-beta ?l - location)

    (sealed ?r - robot)
    (unsealed ?r - robot)
    (seismic-active)
    (seismic-clear)

    (can-fly ?r - robot)
    (can-carry-pod ?r - robot)

    (is-fragile ?a - artifact)
    (not-fragile ?a - artifact)
    (is-alpha ?a - artifact)
    (is-core-sample ?a - artifact)

    (stabilized ?a - artifact)
    (cooled ?a - artifact)
    (pending-cool ?a - artifact)
  )

  ;; ---- movement. All rooms are reachable with the maintenance tunnel at the center of the map ------
  (:durative-action move_via_tunnel
    :parameters (?r - robot ?from - location ?to - location)
    :duration (= ?duration 3)
    :condition (and
      (at start (robot-at ?r ?from))
      (at start (tunnel-connected ?from ?to))
      (over all (sealed ?r)))
    :effect (and
      (at start (not (robot-at ?r ?from)))
      (at end (robot-at ?r ?to)))
  )

  (:durative-action move_via_tunnel_to_beta
    :parameters (?r - robot ?from - location ?to - location)
    :duration (= ?duration 3)
    :condition (and
      (at start (robot-at ?r ?from))
      (at start (tunnel-beta-connected ?from ?to))
      (over all (sealed ?r))
      (over all (seismic-clear)))
    :effect (and
      (at start (not (robot-at ?r ?from)))
      (at end (robot-at ?r ?to)))
  )

  ;; ---- sealing mode for maintenance tunnel crossing of robot curator ---------------------

  (:durative-action activate_sealing
    :parameters (?r - robot)
    :duration (= ?duration 1)
    :condition (at start (unsealed ?r))
    :effect (and
      (at start (not (unsealed ?r)))
      (at end (sealed ?r)))
  )

  (:durative-action deactivate_sealing
    :parameters (?r - robot)
    :duration (= ?duration 1)
    :condition (at start (sealed ?r))
    :effect (and
      (at start (not (sealed ?r)))
      (at end (unsealed ?r)))
  )

  ;; ---- aerial movement for drone. No tunnel sealing needed -----

  (:durative-action fly
    :parameters (?r - robot ?from - location ?to - location)
    :duration (= ?duration 2)
    :condition (and
      (at start (robot-at ?r ?from))
      (at start (can-fly ?r))
      (at start (not-hall-beta ?from))
      (at start (not-hall-beta ?to)))
    :effect (and
      (at start (not (robot-at ?r ?from)))
      (at end (robot-at ?r ?to)))
  )

  (:durative-action fly_to_beta
    :parameters (?r - robot ?from - location ?to - location)
    :duration (= ?duration 2)
    :condition (and
      (at start (robot-at ?r ?from))
      (at start (can-fly ?r))
      (at start (is-hall-beta ?to))
      (over all (seismic-clear)))
    :effect (and
      (at start (not (robot-at ?r ?from)))
      (at end (robot-at ?r ?to)))
  )

  (:durative-action fly_from_beta
    :parameters (?r - robot ?from - location ?to - location)
    :duration (= ?duration 2)
    :condition (and
      (at start (robot-at ?r ?from))
      (at start (can-fly ?r))
      (at start (is-hall-beta ?from))
      (over all (seismic-clear)))
    :effect (and
      (at start (not (robot-at ?r ?from)))
      (at end (robot-at ?r ?to)))
  )

  ;; ---- handling pods. Robot curator only, requires can-carry-pod ----------------
  ;; "over all (robot-at ?r ?l)" pins the robot in place for the whole
  ;; manipulation. Makes it mutually exclusive with all move actions on the same robot 
  ;; (Example in pdf: a robot cannot pick something up and fly away at the same time)

  (:durative-action pickup_pod
    :parameters (?r - robot ?p - pod ?l - location ?s - slot)
    :duration (= ?duration 1)
    :condition (and
      (over all (robot-at ?r ?l))
      (at start (at-pod ?p ?l))
      (at start (can-carry-pod ?r))
      (at start (slot-of ?s ?r))
      (at start (slot-free ?s)))
    :effect (and
      (at start (not (at-pod ?p ?l)))
      (at start (not (slot-free ?s)))
      (at end (holding-pod ?s ?p)))
  )

  (:durative-action putdown_pod
    :parameters (?r - robot ?p - pod ?l - location ?s - slot)
    :duration (= ?duration 1)
    :condition (and
      (over all (robot-at ?r ?l))
      (at start (slot-of ?s ?r))
      (at start (holding-pod ?s ?p)))
    :effect (and
      (at start (not (holding-pod ?s ?p)))
      (at end (at-pod ?p ?l))
      (at end (slot-free ?s)))
  )

  ;; ---- handling non-fragile artifacts directly -----------------------------

  (:durative-action pickup_artifact
    :parameters (?r - robot ?a - artifact ?l - location ?s - slot)
    :duration (= ?duration 1)
    :condition (and
      (over all (robot-at ?r ?l))
      (at start (at-artifact ?a ?l))
      (at start (not-fragile ?a))
      (at start (slot-of ?s ?r))
      (at start (slot-free ?s)))
    :effect (and
      (at start (not (at-artifact ?a ?l)))
      (at start (not (slot-free ?s)))
      (at end (holding-artifact ?s ?a)))
  )

  (:durative-action putdown_artifact
    :parameters (?r - robot ?a - artifact ?l - location ?s - slot)
    :duration (= ?duration 1)
    :condition (and
      (over all (robot-at ?r ?l))
      (at start (slot-of ?s ?r))
      (at start (holding-artifact ?s ?a)))
    :effect (and
      (at start (not (holding-artifact ?s ?a)))
      (at end (at-artifact ?a ?l))
      (at end (slot-free ?s)))
  )

  ;; ---- handling fragile artifacts (must go inside a pod) ------
  ;; The robot has to be carrying a pod, travel to the artifact and load it in pod.

  (:durative-action secure_in_pod
    :parameters (?r - robot ?a - artifact ?p - pod ?l - location ?s - slot)
    :duration (= ?duration 2)
    :condition (and
      (over all (robot-at ?r ?l))
      (over all (holding-pod ?s ?p))
      (at start (slot-of ?s ?r))
      (at start (at-artifact ?a ?l))
      (at start (is-fragile ?a)))
    :effect (and
      (at start (not (at-artifact ?a ?l)))
      (at end (in-pod ?a ?p))
      (at end (stabilized ?a)))
  )

  (:durative-action unload_from_pod
    :parameters (?r - robot ?a - artifact ?p - pod ?l - location ?s - slot)
    :duration (= ?duration 2)
    :condition (and
      (over all (robot-at ?r ?l))
      (over all (holding-pod ?s ?p))
      (at start (slot-of ?s ?r))
      (at start (in-pod ?a ?p)))
    :effect (and
      (at start (not (in-pod ?a ?p)))
      (at end (at-artifact ?a ?l)))
  )

  ;; ---- handling alpha artifacts and fragile alpha artifacts (must be cooled down) ------
  ;; "over all (holding ...)" so the item can't be put down during cooling.
  ;; Now tied to robot-at, cooling can't overlap with movement.

  (:durative-action cool
    :parameters (?r - robot ?a - artifact ?s - slot ?l - location)
    :duration (= ?duration 3)
    :condition (and
      (over all (robot-at ?r ?l))
      (over all (holding-artifact ?s ?a))
      (at start (slot-of ?s ?r))
      (at start (is-alpha ?a))
      (at start (pending-cool ?a)))
    :effect (and
      (at start (not (pending-cool ?a)))
      (at end (cooled ?a)))
  )

  (:durative-action cool_in_pod
    :parameters (?r - robot ?a - artifact ?p - pod ?s - slot ?l - location)
    :duration (= ?duration 3)
    :condition (and
      (over all (robot-at ?r ?l))
      (over all (holding-pod ?s ?p))
      (over all (in-pod ?a ?p))
      (at start (slot-of ?s ?r))
      (at start (is-alpha ?a))
      (at start (pending-cool ?a)))
    :effect (and
      (at start (not (pending-cool ?a)))
      (at end (cooled ?a)))
  )
)
