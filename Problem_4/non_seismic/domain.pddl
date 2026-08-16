;; ==========================================================================
;; Domain: Interplanetary Museum Vault (IMV) - Problem 4
;;
;; Convert Problem 2's domain to durative actions. Durations are arbitrary
;; and expressed in minutes. Actions may run in parallel.
;;
;;NB: POPF and OPTIC don't support negative literals in action preconditions. Running we get
;; unsupported ADL. So conversions incomplementary positive predicate:
;;   (not (sealed ?r))        -> (unsealed ?r)
;;   (not (is-fragile ?a))    -> (not-fragile ?a)      
;;   (not (cooled ?a))        -> (pending-cool ?a)     
;;   (not (is-hall-beta ?l))  -> (not-hall-beta ?l)    
;;   (not (seismic-active))   -> (seismic-clear)
;; ==========================================================================

(define (domain imv-transport-temporal-non-seismic)

  (:requirements :strips :typing :durative-actions)

  (:types
    item
    artifact pod - item
    robot location slot
  )

  (:predicates
    (at ?x - item ?l - location)
    (robot-at ?r - robot ?l - location)

    (slot-of ?s - slot ?r - robot)
    (slot-free ?s - slot)
    (holding ?s - slot ?x - item)

    (in-pod ?a - artifact ?p - pod)

    (tunnel-connected ?l1 - location ?l2 - location)
    (tunnel-beta-connected ?l1 - location ?l2 - location)
    (is-hall-beta ?l - location)
    (not-hall-beta ?l - location)          ; complement of is-hall-beta

    (sealed ?r - robot)
    (unsealed ?r - robot)                  ; complement of sealed
    (seismic-active)
    (seismic-clear)                        ; complement of seismic-active

    (can-fly ?r - robot)
    (can-carry-pod ?r - robot)

    (is-fragile ?a - artifact)
    (not-fragile ?a - artifact)            ; complement of is-fragile
    (is-alpha ?a - artifact)
    (is-core-sample ?a - artifact)

    (stabilized ?a - artifact)
    (cooled ?a - artifact)
    (pending-cool ?a - artifact)           ; true until a is cooled
  )

  ;; ---- movement. All rooms are reachable with the maintenance tunnel at the center of the map ------
  ;; Sealing must hold for the whole crossing, not only at departure

  (:durative-action move-via-tunnel
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

  (:durative-action move-via-tunnel-to-beta
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

  (:durative-action activate-sealing
    :parameters (?r - robot)
    :duration (= ?duration 1)
    :condition (at start (unsealed ?r))
    :effect (and
      (at start (not (unsealed ?r)))
      (at end (sealed ?r)))
  )

  (:durative-action deactivate-sealing
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

  (:durative-action fly-to-beta
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

  (:durative-action fly-from-beta
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

  (:durative-action pickup-pod
    :parameters (?r - robot ?p - pod ?l - location ?s - slot)
    :duration (= ?duration 1)
    :condition (and
      (over all (robot-at ?r ?l))
      (at start (at ?p ?l))
      (at start (can-carry-pod ?r))
      (at start (slot-of ?s ?r))
      (at start (slot-free ?s)))
    :effect (and
      (at start (not (at ?p ?l)))
      (at start (not (slot-free ?s)))
      (at end (holding ?s ?p)))
  )

  (:durative-action putdown-pod
    :parameters (?r - robot ?p - pod ?l - location ?s - slot)
    :duration (= ?duration 1)
    :condition (and
      (over all (robot-at ?r ?l))
      (at start (slot-of ?s ?r))
      (at start (holding ?s ?p)))
    :effect (and
      (at start (not (holding ?s ?p)))
      (at end (at ?p ?l))
      (at end (slot-free ?s)))
  )

  ;; ---- handling non-fragile artifacts directly -----------------------------

  (:durative-action pickup-artifact
    :parameters (?r - robot ?a - artifact ?l - location ?s - slot)
    :duration (= ?duration 1)
    :condition (and
      (over all (robot-at ?r ?l))
      (at start (at ?a ?l))
      (at start (not-fragile ?a))
      (at start (slot-of ?s ?r))
      (at start (slot-free ?s)))
    :effect (and
      (at start (not (at ?a ?l)))
      (at start (not (slot-free ?s)))
      (at end (holding ?s ?a)))
  )

  (:durative-action putdown-artifact
    :parameters (?r - robot ?a - artifact ?l - location ?s - slot)
    :duration (= ?duration 1)
    :condition (and
      (over all (robot-at ?r ?l))
      (at start (slot-of ?s ?r))
      (at start (holding ?s ?a)))
    :effect (and
      (at start (not (holding ?s ?a)))
      (at end (at ?a ?l))
      (at end (slot-free ?s)))
  )

  ;; ---- handling fragile artifacts (must go inside a pod) ------
  ;; The robot has to be carrying a pod, travel to the artifact and load it in pod.

  (:durative-action secure-in-pod
    :parameters (?r - robot ?a - artifact ?p - pod ?l - location ?s - slot)
    :duration (= ?duration 2)
    :condition (and
      (over all (robot-at ?r ?l))
      (over all (holding ?s ?p))
      (at start (slot-of ?s ?r))
      (at start (at ?a ?l))
      (at start (is-fragile ?a)))
    :effect (and
      (at start (not (at ?a ?l)))
      (at end (in-pod ?a ?p))
      (at end (stabilized ?a)))
  )

  (:durative-action unload-from-pod
    :parameters (?r - robot ?a - artifact ?p - pod ?l - location ?s - slot)
    :duration (= ?duration 2)
    :condition (and
      (over all (robot-at ?r ?l))
      (over all (holding ?s ?p))
      (at start (slot-of ?s ?r))
      (at start (in-pod ?a ?p)))
    :effect (and
      (at start (not (in-pod ?a ?p)))
      (at end (at ?a ?l)))
  )

  ;; ---- handling alpha artifacts and fragile alpha artifacts (must be cooled down) ------
  ;; The portable cooling unit keeps running while the robot travels.
  ;; "over all (holding ...)" so the item can't be put down during cooling.
  ;; Not tied to robot-at, so cooling can overlap with movement.

  (:durative-action cool
    :parameters (?r - robot ?a - artifact ?s - slot)
    :duration (= ?duration 3)
    :condition (and
      (over all (holding ?s ?a))
      (at start (slot-of ?s ?r))
      (at start (is-alpha ?a))
      (at start (pending-cool ?a)))
    :effect (and
      (at start (not (pending-cool ?a)))
      (at end (cooled ?a)))
  )

  (:durative-action cool-in-pod
    :parameters (?r - robot ?a - artifact ?p - pod ?s - slot)
    :duration (= ?duration 3)
    :condition (and
      (over all (holding ?s ?p))
      (over all (in-pod ?a ?p))
      (at start (slot-of ?s ?r))
      (at start (is-alpha ?a))
      (at start (pending-cool ?a)))
    :effect (and
      (at start (not (pending-cool ?a)))
      (at end (cooled ?a)))
  )
)
