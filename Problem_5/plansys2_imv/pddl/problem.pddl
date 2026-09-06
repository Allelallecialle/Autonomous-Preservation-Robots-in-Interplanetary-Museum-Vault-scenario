(define (problem imv-plansys2)
  (:domain imv-transport-plansys2)

  (:objects
    curator1 drone1 - robot
    slot-c1a slot-c1b slot-d1a - slot
    pod1 pod2 - pod
    art-beta-1 art-beta-2 art-alpha-1 art-alpha-2 core-sample-1 - artifact
    entrance tunnel anti-vibration-pods hall-alpha hall-beta cryo-chamber stasis-lab - location
  )

  (:init
    (robot-at curator1 entrance)
    (robot-at drone1 entrance)
    (unsealed curator1)
    (unsealed drone1)

    (slot-of slot-c1a curator1)
    (slot-of slot-c1b curator1)
    (slot-free slot-c1a)
    (slot-free slot-c1b)

    (slot-of slot-d1a drone1)
    (slot-free slot-d1a)

    (can-carry-pod curator1)
    (can-fly drone1)

    (at-pod pod1 anti-vibration-pods)
    (at-pod pod2 anti-vibration-pods)

    (at-artifact art-beta-1 hall-beta)
    (at-artifact art-beta-2 hall-beta)
    (at-artifact art-alpha-1 hall-alpha)
    (at-artifact art-alpha-2 hall-alpha)
    (at-artifact core-sample-1 cryo-chamber)

    (is-fragile art-beta-2)
    (is-alpha art-alpha-1)
    (is-alpha art-alpha-2)
    (is-fragile art-alpha-2)
    (is-core-sample core-sample-1)

    (not-fragile art-beta-1)
    (not-fragile art-alpha-1)
    (not-fragile core-sample-1)

    (pending-cool art-alpha-1)
    (pending-cool art-alpha-2)

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
    (not-hall-beta entrance)
    (not-hall-beta tunnel)
    (not-hall-beta anti-vibration-pods)
    (not-hall-beta hall-alpha)
    (not-hall-beta cryo-chamber)
    (not-hall-beta stasis-lab)

    (seismic-clear)
  )

  (:goal
    (and
      (at-artifact art-beta-1 stasis-lab)
      (stabilized art-beta-2) (at-artifact art-beta-2 stasis-lab)
      (cooled art-alpha-1) (at-artifact art-alpha-1 cryo-chamber)
      (stabilized art-alpha-2) (cooled art-alpha-2) (at-artifact art-alpha-2 cryo-chamber)
      (at-artifact core-sample-1 stasis-lab)
    )
  )
)
