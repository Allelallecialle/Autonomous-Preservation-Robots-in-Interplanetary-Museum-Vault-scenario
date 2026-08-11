;; ==========================================================================
;; Domain: Interplanetary Museum Vault (IMV) - Problem 2
;;
;; Extension of Problem 1:
;;  - multiple agent with different capabilities (robotic curator + drone)
;;  - maximum carrying capacity per agent, modelled as a fixed number of
;;     slot objects per robot (kept in plain STRIPS, no numeric
;;     fluents so the domain stays solvable by the same planners as Problem 1)
;; ==========================================================================

(define (domain imv-transport-multi)

  (:requirements :strips :typing :negative-preconditions)

  (:types
    item
    artifact pod - item
    robot location slot
  )

  (:predicates
    (at ?x - item ?l - location)               ; item x (artifact or pod) is at location l
    (robot-at ?r - robot ?l - location)         ; robot r is at location l

    (slot-of ?s - slot ?r - robot)               ; slot s belongs to robot r
    (slot-free ?s - slot)                        ; slot s empty
    (holding ?s - slot ?x - item)                ; slot s holding item x

    (in-pod ?a - artifact ?p - pod)              ; artifact a is secured inside pod p

    (tunnel-connected ?l1 - location ?l2 - location)      ; room <-> maintenance tunnel passage (ground for robot curator)
    (tunnel-beta-connected ?l1 - location ?l2 - location) ; Hall beta (seismic) <-> maintenance tunnel passage (ground for robot curator)
    (is-hall-beta ?l - location)                 ; marks Hall beta for drone flight preconditions

    (sealed ?r - robot)                          ; robot r has sealing mode active (ground robot curator travel only)
    (seismic-active)                             ; a seismic event is currently active

    (can-fly ?r - robot)                         ; robot r is a drone (bypasses the tunnel)
    (can-carry-pod ?r - robot)                   ; robot r is able to carry an anti-vibration pod (only robot curator, not the drone)

    (is-fragile ?a - artifact)                   ; artifact a must be secured in a pod before being moved
    (is-alpha ?a - artifact)                     ; artifact a must be cooled and delivered to the cryo chamber
    (is-core-sample ?a - artifact)                ; artifact a is a martian core sample

    (stabilized ?a - artifact)                   ; artifact a has been secured in a pod
    (cooled ?a - artifact)                   ; artifact a has been cooled
  )

  ;; ---- movement. All rooms are reachable with the maintenance tunnel at the center of the map ------

  (:action move-via-tunnel
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and (robot-at ?r ?from) (tunnel-connected ?from ?to) (sealed ?r))
    :effect (and (robot-at ?r ?to) (not (robot-at ?r ?from)))
  )

  (:action move-via-tunnel-to-beta
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and (robot-at ?r ?from) (tunnel-beta-connected ?from ?to)
                        (sealed ?r) (not (seismic-active)))
    :effect (and (robot-at ?r ?to) (not (robot-at ?r ?from)))
  )

;; ---- sealing mode for maintenance tunnel crossing of robot curator ---------------------
  (:action activate-sealing
    :parameters (?r - robot)
    :precondition (not (sealed ?r))
    :effect (sealed ?r)
  )

  (:action deactivate-sealing
    :parameters (?r - robot)
    :precondition (sealed ?r)
    :effect (not (sealed ?r))
  )

  ;; ---- aerial movement for drone. No tunnel sealing needed -----

  (:action fly
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and (robot-at ?r ?from) (can-fly ?r)
                        (not (is-hall-beta ?from)) (not (is-hall-beta ?to)))
    :effect (and (robot-at ?r ?to) (not (robot-at ?r ?from)))
  )

  (:action fly-to-beta
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and (robot-at ?r ?from) (can-fly ?r)
                        (is-hall-beta ?to) (not (seismic-active)))
    :effect (and (robot-at ?r ?to) (not (robot-at ?r ?from)))
  )

  (:action fly-from-beta
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and (robot-at ?r ?from) (can-fly ?r)
                        (is-hall-beta ?from) (not (seismic-active)))
    :effect (and (robot-at ?r ?to) (not (robot-at ?r ?from)))
  )

  ;; ---- handling pods. Robot curator only, requires can-carry-pod ----------------

  (:action pickup-pod
    :parameters (?r - robot ?p - pod ?l - location ?s - slot)
    :precondition (and (robot-at ?r ?l) (at ?p ?l) (can-carry-pod ?r)
                        (slot-of ?s ?r) (slot-free ?s))
    :effect (and (holding ?s ?p) (not (at ?p ?l)) (not (slot-free ?s)))
  )

  (:action putdown-pod
    :parameters (?r - robot ?p - pod ?l - location ?s - slot)
    :precondition (and (robot-at ?r ?l) (slot-of ?s ?r) (holding ?s ?p))
    :effect (and (at ?p ?l) (slot-free ?s) (not (holding ?s ?p)))
  )

  ;; ---- handling non-fragile artifacts directly -----------------------------

  (:action pickup-artifact
    :parameters (?r - robot ?a - artifact ?l - location ?s - slot)
    :precondition (and (robot-at ?r ?l) (at ?a ?l) (not (is-fragile ?a))
                        (slot-of ?s ?r) (slot-free ?s))
    :effect (and (holding ?s ?a) (not (at ?a ?l)) (not (slot-free ?s)))
  )

  (:action putdown-artifact
    :parameters (?r - robot ?a - artifact ?l - location ?s - slot)
    :precondition (and (robot-at ?r ?l) (slot-of ?s ?r) (holding ?s ?a))
    :effect (and (at ?a ?l) (slot-free ?s) (not (holding ?s ?a)))
  )

  ;; ---- handling fragile artifacts (must go inside a pod) ------
  ;; The robot has to be carrying a pod, travel to the artifact and load it in pod.

  (:action secure-in-pod
    :parameters (?r - robot ?a - artifact ?p - pod ?l - location ?s - slot)
    :precondition (and (robot-at ?r ?l) (slot-of ?s ?r) (holding ?s ?p)
                        (at ?a ?l) (is-fragile ?a))
    :effect (and (in-pod ?a ?p) (stabilized ?a) (not (at ?a ?l)))
  )

  (:action unload-from-pod
    :parameters (?r - robot ?a - artifact ?p - pod ?l - location ?s - slot)
    :precondition (and (robot-at ?r ?l) (slot-of ?s ?r) (holding ?s ?p) (in-pod ?a ?p))
    :effect (and (at ?a ?l) (not (in-pod ?a ?p)))
  )

  ;; ---- handling alpha artifacts (must be cooled down) ------

  (:action cool
    :parameters (?r - robot ?a - artifact ?s - slot)
    :precondition (and (slot-of ?s ?r) (holding ?s ?a) (is-alpha ?a) (not (cooled ?a)))
    :effect (cooled ?a)
  )

 ;; ---- handling fragile alpha artifacts (must be cooled down + put inside a pod) ------
  (:action cool-in-pod
    :parameters (?r - robot ?a - artifact ?p - pod ?s - slot)
    :precondition (and (slot-of ?s ?r) (holding ?s ?p) (in-pod ?a ?p)
                        (is-alpha ?a) (not (cooled ?a)))
    :effect (cooled ?a)
  )
)
