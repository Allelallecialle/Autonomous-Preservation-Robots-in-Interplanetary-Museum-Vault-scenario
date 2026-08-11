(define (problem imv-transport-p2)
  (:domain imv-transport-multi)

  (:objects
    curator1 - robot
    drone1 - robot
    slot-c1a slot-c1b - slot   ; curator1 has capacity 2
    slot-d1a - slot            ; drone1 has capacity 1
    pod1 pod2 - pod
    art-beta-1                - artifact  ; common item (not fragile) from Hall beta
    art-beta-2                - artifact  ; fragile item from Hall beta
    art-alpha-1               - artifact  ; alpha item, not fragile
    art-alpha-2                - artifact  ; alpha item + fragile
    core-sample-1              - artifact  ; Martian Core Sample
    entrance tunnel anti-vibration-pods hall-alpha hall-beta cryo-chamber stasis-lab - location
  )

  (:init
    ;; robots
    (robot-at curator1 entrance)
    (robot-at drone1 entrance)

    ;; robot slots
    (slot-of slot-c1a curator1)
    (slot-of slot-c1b curator1)
    (slot-free slot-c1a)
    (slot-free slot-c1b)

    ;; drone slots
    (slot-of slot-d1a drone1)
    (slot-free slot-d1a)

    ;; curators' capabilities
    (can-carry-pod curator1)   ; only the robot curator can handle pods
    (can-fly drone1)           ; only the drone bypasses the tunnel

    ;; pods start stored in the Anti-Vibration Pods room
    (at pod1 anti-vibration-pods)
    (at pod2 anti-vibration-pods)

    ;; artifacts' initial locations
    (at art-beta-1 hall-beta)
    (at art-beta-2 hall-beta)
    (at art-alpha-1 hall-alpha)
    (at art-alpha-2 hall-alpha)
    (at core-sample-1 cryo-chamber)

    ;; artifact characteristics
    (is-fragile art-beta-2)
    (is-alpha art-alpha-1)
    (is-alpha art-alpha-2)
    (is-fragile art-alpha-2)
    (is-core-sample core-sample-1)

    ;; map topology: every room hangs off the Maintenance Tunnel (ground travel)
    (tunnel-connected entrance tunnel)
    (tunnel-connected tunnel entrance)
    (tunnel-connected anti-vibration-pods tunnel)
    (tunnel-connected tunnel anti-vibration-pods)
    (tunnel-connected hall-alpha tunnel)
    (tunnel-connected tunnel hall-alpha)
    (tunnel-connected cryo-chamber tunnel)
    (tunnel-connected tunnel cryo-chamber)
    (tunnel-connected stasis-lab tunnel)
    (tunnel-connected tunnel stasis-lab)

    (tunnel-beta-connected hall-beta tunnel)
    (tunnel-beta-connected tunnel hall-beta)

    ;; drone flight only needs to know which room is the seismic sensitive one
    (is-hall-beta hall-beta)

    ;; map properties: 
    ;;(seismic-active) deliberately absent
  )

  (:goal
    ;; as in Problem 1
    (and
      (at art-beta-1 stasis-lab)
      (stabilized art-beta-2) (at art-beta-2 stasis-lab)
      (cooled art-alpha-1) (at art-alpha-1 cryo-chamber)
      (stabilized art-alpha-2) (cooled art-alpha-2) (at art-alpha-2 cryo-chamber)
      (at core-sample-1 stasis-lab)
    )
  )
)
