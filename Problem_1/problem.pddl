(define (problem imv-transport-p1)
  (:domain imv-transport)

  (:objects
    curator1 - robot
    pod1 pod2 - pod
    art-beta-1                - artifact  ; common item (not fragile) from Hall beta
    art-beta-2                - artifact  ; fragile item from Hall beta
    art-alpha-1               - artifact  ; alpha item, not fragile
    art-alpha-2               - artifact  ; alpha item + fragile
    core-sample-1             - artifact  ; Martian Core Sample
    ;; map locations:
    entrance tunnel anti-vibration-pods hall-alpha hall-beta cryo-chamber stasis-lab - location
  )

  (:init
    ;; robot
    (robot-at curator1 entrance)
    (free curator1)

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
    ;;false (is-fragile art-beta-1)) -> art-beta-1 is common artifact

    (is-fragile art-beta-2) ; art-beta-2 is fragile

    (is-alpha art-alpha-1)  ; art-alpha-1 only needs cooling

    (is-alpha art-alpha-2)
    (is-fragile art-alpha-2)          ; art-alpha-2 has both characteristics (fragile+cooling)

    (is-core-sample core-sample-1)



    ;; map topology from assignment image: every room hangs off the maintenance tunnel
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

    ;; map properties
    ;;((seismic-active))   ;; seismic activity false or the artifacts in beta can't be picked. Activate with time windows
  )

  (:goal
    (and
      ;; common artifact from Hall beta: secured in a pod, delivered to Stasis-Lab
      (at art-beta-1 stasis-lab)
      ;; fragile artifacts from Hall beta: secured in a pod, delivered to Stasis-Lab
      (stabilized art-beta-2) (at art-beta-2 stasis-lab)

      ;; alpha artifact (not fragile): cooled, delivered to the Cryo-Chamber
      (cooled art-alpha-1) (at art-alpha-1 cryo-chamber)

      ;; alpha artifact + fragile: secured in a pod, delivered to the Cryo-Chamber
      (stabilized art-alpha-2) (cooled art-alpha-2) (at art-alpha-2 cryo-chamber)

      ;; Martian Core Sample: relocated from the Cryo-Chamber to the Stasis-Lab
      (at core-sample-1 stasis-lab)
    )
  )
)
