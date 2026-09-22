;; ==========================================================================
;; Domain: Interplanetary Museum Vault (IMV) - Problem 2 with pod capacity patch
;;
;; Same as Problem 2's domain, with one added constraint: a pod can hold at
;; most one artifact at a time since secure-in-pod never checked if the pod already
;; held something.
;; ==========================================================================

(define (domain imv-transport-multi-pod-capacity)

  (:requirements :strips :typing :negative-preconditions)

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
    (pod-empty ?p - pod)                         ; NEW: pod p currently holds no artifact

    (tunnel-connected ?l1 - location ?l2 - location)
    (tunnel-beta-connected ?l1 - location ?l2 - location)
    (is-hall-beta ?l - location)

    (sealed ?r - robot)
    (seismic-active)

    (can-fly ?r - robot)
    (can-carry-pod ?r - robot)

    (is-fragile ?a - artifact)
    (is-alpha ?a - artifact)
    (is-core-sample ?a - artifact)

    (stabilized ?a - artifact)
    (cooled ?a - artifact)
  )

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

  ;; ---- handling fragile artifacts ------
  ;; NEW: the pod must be empty before an artifact can be secured in it.
  
  (:action secure-in-pod
    :parameters (?r - robot ?a - artifact ?p - pod ?l - location ?s - slot)
    :precondition (and (robot-at ?r ?l) (slot-of ?s ?r) (holding ?s ?p)
                        (at ?a ?l) (is-fragile ?a) (pod-empty ?p))
    :effect (and (in-pod ?a ?p) (stabilized ?a) (not (at ?a ?l)) (not (pod-empty ?p)))
  )

  (:action unload-from-pod
    :parameters (?r - robot ?a - artifact ?p - pod ?l - location ?s - slot)
    :precondition (and (robot-at ?r ?l) (slot-of ?s ?r) (holding ?s ?p) (in-pod ?a ?p))
    :effect (and (at ?a ?l) (not (in-pod ?a ?p)) (pod-empty ?p))
  )

  (:action cool
    :parameters (?r - robot ?a - artifact ?s - slot)
    :precondition (and (slot-of ?s ?r) (holding ?s ?a) (is-alpha ?a) (not (cooled ?a)))
    :effect (cooled ?a)
  )

  (:action cool-in-pod
    :parameters (?r - robot ?a - artifact ?p - pod ?s - slot)
    :precondition (and (slot-of ?s ?r) (holding ?s ?p) (in-pod ?a ?p)
                        (is-alpha ?a) (not (cooled ?a)))
    :effect (cooled ?a)
  )
)