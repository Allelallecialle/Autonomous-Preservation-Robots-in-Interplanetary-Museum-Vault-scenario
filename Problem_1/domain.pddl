; ==========================================================================
; Domain: Interplanetary Museum Vault (IMV) - Problem 1
;
; Single robotic curator, classical STRIPS-style planning
; ==========================================================================

(define (domain imv-transport)

  (:requirements :strips :typing :negative-preconditions)

  (:types
    item
    artifact pod - item
    robot location
  )

  (:predicates
    (at ?x - item ?l - location)               ; item x (artifact or pod) is at location l
    (robot-at ?r - robot ?l - location)         ; robot r is at location l
    (carrying ?r - robot ?x - item)             ; robot r is carrying item x (artifact or pod)
    (free ?r - robot)                           ; robot r is carrying nothing
    
    (tunnel-connected ?l1 - location ?l2 - location)      ; room <-> maintenance tunnel passage
    (tunnel-beta-connected ?l1 - location ?l2 - location) ; Hall beta (seismic) <-> maintenance tunnel passage

    (sealed ?r - robot)                         ; robot r has sealing mode active
    (seismic-active)                            ; a seismic event is currently active

    (in-pod ?a - artifact ?p - pod)             ; artifact a is currently secured inside pod p
    (is-fragile ?a - artifact)                  ; artifact a must be secured in a pod before being moved
    (is-alpha ?a - artifact)                    ; artifact a must be cooled and delivered to the cryo chamber
    (is-core-sample ?a - artifact)           ; artifact a is a martian core sample

    (stabilized ?a - artifact)                  ; artifact a has, at some point, been secured in a pod (persists)
    (cooled ?a - artifact)                      ; artifact a has been cooled
  )

  ;; ---- movement. All rooms are reachable with the maintenance tunnel at the center of the map ------

  (:action move-via-tunnel
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and (robot-at ?r ?from)
                        (tunnel-connected ?from ?to)
                        (sealed ?r))
    :effect (and (robot-at ?r ?to) (not (robot-at ?r ?from)))
  )

  (:action move-via-tunnel-to-beta
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and (robot-at ?r ?from)
                        (tunnel-beta-connected ?from ?to)
                        (sealed ?r)
                        (not (seismic-active)))
    :effect (and (robot-at ?r ?to) (not (robot-at ?r ?from)))
  )

  ;; ---- sealing mode for maintenance tunnel crossing ---------------------

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

  ;; ---- handling pods -----

  (:action pickup-pod
    :parameters (?r - robot ?p - pod ?l - location)
    :precondition (and (robot-at ?r ?l) (at ?p ?l) (free ?r))
    :effect (and (carrying ?r ?p) (not (at ?p ?l)) (not (free ?r)))
  )

  (:action putdown-pod
    :parameters (?r - robot ?p - pod ?l - location)
    :precondition (and (robot-at ?r ?l) (carrying ?r ?p))
    :effect (and (at ?p ?l) (free ?r) (not (carrying ?r ?p)))
  )

  ;; ---- handling non-fragile artifacts directly -----
  ;; check if there's no seismic activity

  (:action pickup-artifact
    :parameters (?r - robot ?a - artifact ?l - location)
    :precondition (and (robot-at ?r ?l) (at ?a ?l) (free ?r) (not (is-fragile ?a)))
    :effect (and (carrying ?r ?a) (not (at ?a ?l)) (not (free ?r)))
  )

  (:action putdown-artifact
    :parameters (?r - robot ?a - artifact ?l - location)
    :precondition (and (robot-at ?r ?l) (carrying ?r ?a))
    :effect (and (at ?a ?l) (free ?r) (not (carrying ?r ?a)))
  )

  ;; ---- handling fragile artifacts (must go inside a pod) ------
  ;; The robot has to be carrying a pod, travel to the artifact and load it in pod.Check if there's no seismic activity

  (:action secure-in-pod
    :parameters (?r - robot ?a - artifact ?p - pod ?l - location)
    :precondition (and (robot-at ?r ?l) (carrying ?r ?p) (at ?a ?l) (is-fragile ?a))
    :effect (and (in-pod ?a ?p) (stabilized ?a) (not (at ?a ?l)))
  )

  (:action unload-from-pod
    :parameters (?r - robot ?a - artifact ?p - pod ?l - location)
    :precondition (and (robot-at ?r ?l) (carrying ?r ?p) (in-pod ?a ?p))
    :effect (and (at ?a ?l) (not (in-pod ?a ?p)))
  )

  ;; ---- handling alpha artifacts (must be cooled down) ------

  (:action cool
    :parameters (?r - robot ?a - artifact)
    :precondition (and (carrying ?r ?a) (is-alpha ?a) (not (cooled ?a)))
    :effect (cooled ?a)
  )

  ;; ---- handling fragile alpha artifacts (must be cooled down + put inside a pod) ------

  (:action cool-in-pod
    :parameters (?r - robot ?a - artifact ?p - pod)
    :precondition (and (carrying ?r ?p) (in-pod ?a ?p) (is-alpha ?a) (not (cooled ?a)))
    :effect (cooled ?a)
  )
)
