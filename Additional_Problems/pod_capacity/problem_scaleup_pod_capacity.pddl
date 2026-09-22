;; Same problem as scaleup experiment but with constrained pod capacity

(define (problem imv-transport-p2-scaleup-podcap)
  (:domain imv-transport-multi-pod-capacity)

  (:objects
    curator1 - robot
    drone1 - robot
    slot-c1a slot-c1b - slot
    slot-d1a - slot
    pod1 pod2 - pod
    art-beta-1 art-beta-2 art-beta-3 art-beta-4 - artifact
    art-alpha-1 art-alpha-2 art-alpha-3 art-alpha-4 - artifact
    core-sample-1 core-sample-2 - artifact
    entrance tunnel anti-vibration-pods hall-alpha hall-beta cryo-chamber stasis-lab - location
  )

  (:init
    (robot-at curator1 entrance)
    (robot-at drone1 entrance)

    (slot-of slot-c1a curator1)
    (slot-of slot-c1b curator1)
    (slot-free slot-c1a)
    (slot-free slot-c1b)

    (slot-of slot-d1a drone1)
    (slot-free slot-d1a)

    (can-carry-pod curator1)
    (can-fly drone1)

    (at pod1 anti-vibration-pods)
    (at pod2 anti-vibration-pods)
    (pod-empty pod1)                              ; NEW
    (pod-empty pod2)                              ; NEW

    (at art-beta-1 hall-beta)
    (at art-beta-2 hall-beta)
    (at art-beta-3 hall-beta)
    (at art-beta-4 hall-beta)
    (at art-alpha-1 hall-alpha)
    (at art-alpha-2 hall-alpha)
    (at art-alpha-3 hall-alpha)
    (at art-alpha-4 hall-alpha)
    (at core-sample-1 cryo-chamber)
    (at core-sample-2 cryo-chamber)

    (is-fragile art-beta-2)
    (is-fragile art-beta-3)
    (is-alpha art-alpha-1)
    (is-alpha art-alpha-2)
    (is-fragile art-alpha-2)
    (is-alpha art-alpha-3)
    (is-fragile art-alpha-3)
    (is-alpha art-alpha-4)
    (is-core-sample core-sample-1)
    (is-core-sample core-sample-2)

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

    (is-hall-beta hall-beta)
  )

  (:goal
    (and
      (at art-beta-1 stasis-lab)
      (stabilized art-beta-2) (at art-beta-2 stasis-lab)
      (stabilized art-beta-3) (at art-beta-3 stasis-lab)
      (at art-beta-4 stasis-lab)
      (cooled art-alpha-1) (at art-alpha-1 cryo-chamber)
      (stabilized art-alpha-2) (cooled art-alpha-2) (at art-alpha-2 cryo-chamber)
      (stabilized art-alpha-3) (cooled art-alpha-3) (at art-alpha-3 cryo-chamber)
      (cooled art-alpha-4) (at art-alpha-4 cryo-chamber)
      (at core-sample-1 stasis-lab)
      (at core-sample-2 stasis-lab)
    )
  )
)