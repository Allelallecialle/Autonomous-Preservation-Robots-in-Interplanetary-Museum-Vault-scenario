;; ===================================================================
;; Problem: "The Martian" Hab - Problem 5 bonus
;;
;; Same domain as IMV scenario (pddl/domain.pddl), only map shape changes.
;; Hybrid shape that combines: a star shaped map as in the assignment; a linear 
;; shaped portion. The asymmetry is useful to see that the drone's ability to 
;; bypass the whole surface route by flying is an advantage.
;;
;;  - The Hab is a single inflatable dome and treated as the old corridor,
;;    so hab-corridor connects to all others internal modules (the airlock,
;;    the hydroponics bay, the med bay, the sample locker, the equipment
;;    workshop). This mirrors the original IMV star topology.
;;
;;  - Long distance EVA excursions across the Martian surface shape 
;;    the linear portion of the map by organizing Watney's journeys to 
;;    recover the Pathfinder probe across multiple waypoint camps.
;;    The Pathfinder recovery site is reachable from the airlock only via
;;     two intermediate surface waypoints.
;;     
;;  - dust-storm windows mirror the seismic-active/seismic-clear predicates
;;    to access the recovery site.
;;
;; Five artifacts and two crates are relocated to fit the map.
;; ======================================================================

(define (problem imv-plansys2-martian-hab)
  (:domain imv-transport-plansys2)

  (:objects
    rover1 recon_drone1 - robot
    slot-r1a slot-r1b slot-d1a - slot
    crate1 crate2 - pod
    soil-sample-1 soil-sample-2 bio-specimen-1 bio-specimen-2 core-sample-1 - artifact
    hab-corridor airlock hydroponics-bay med-bay sample-locker workshop
      solar-farm waypoint-1 waypoint-2 pathfinder-site - location
  )

  (:init
    (robot-at rover1 airlock)
    (robot-at recon_drone1 airlock)
    (unsealed rover1)
    (unsealed recon_drone1)

    (slot-of slot-r1a rover1)
    (slot-of slot-r1b rover1)
    (slot-free slot-r1a)
    (slot-free slot-r1b)

    (slot-of slot-d1a recon_drone1)
    (slot-free slot-d1a)

    (can-carry-pod rover1)
    (can-fly recon_drone1)

    (at-pod crate1 workshop)
    (at-pod crate2 workshop)

    (at-artifact soil-sample-1 solar-farm)
    (at-artifact soil-sample-2 pathfinder-site)
    (at-artifact bio-specimen-1 hydroponics-bay)
    (at-artifact bio-specimen-2 hydroponics-bay)
    (at-artifact core-sample-1 med-bay)

    (is-fragile soil-sample-2)
    (is-alpha bio-specimen-1)
    (is-alpha bio-specimen-2)
    (is-fragile bio-specimen-2)
    (is-core-sample core-sample-1)

    (not-fragile soil-sample-1)
    (not-fragile bio-specimen-1)
    (not-fragile core-sample-1)

    (pending-cool bio-specimen-1)
    (pending-cool bio-specimen-2)

    ;; --------- Hab interior --------
    (tunnel-connected hab-corridor airlock)
    (tunnel-connected airlock hab-corridor)
    (tunnel-connected hab-corridor hydroponics-bay)
    (tunnel-connected hydroponics-bay hab-corridor)
    (tunnel-connected hab-corridor med-bay)
    (tunnel-connected med-bay hab-corridor)
    (tunnel-connected hab-corridor sample-locker)
    (tunnel-connected sample-locker hab-corridor)
    (tunnel-connected hab-corridor workshop)
    (tunnel-connected workshop hab-corridor)

    ;; ---- short EVA: solar farm, one hop from the airlock -------
    (tunnel-connected airlock solar-farm)
    (tunnel-connected solar-farm airlock)

    ;; ---- long EVA: airlock -> waypoint-1 -> waypoint-2 -> Pathfinder site -----
    (tunnel-connected airlock waypoint-1)
    (tunnel-connected waypoint-1 airlock)
    (tunnel-connected waypoint-1 waypoint-2)
    (tunnel-connected waypoint-2 waypoint-1)

    ;; ---- final path to the Pathfinder site has dust-storm check ----
    (tunnel-beta-connected waypoint-2 pathfinder-site)
    (tunnel-beta-connected pathfinder-site waypoint-2)

    (is-hall-beta pathfinder-site)
    (not-hall-beta hab-corridor)
    (not-hall-beta airlock)
    (not-hall-beta hydroponics-bay)
    (not-hall-beta med-bay)
    (not-hall-beta sample-locker)
    (not-hall-beta workshop)
    (not-hall-beta solar-farm)
    (not-hall-beta waypoint-1)
    (not-hall-beta waypoint-2)

    (seismic-clear)
  )

  (:goal
    (and
      (at-artifact soil-sample-1 sample-locker)
      (stabilized soil-sample-2) (at-artifact soil-sample-2 sample-locker)
      (cooled bio-specimen-1) (at-artifact bio-specimen-1 med-bay)
      (stabilized bio-specimen-2) (cooled bio-specimen-2) (at-artifact bio-specimen-2 med-bay)
      (at-artifact core-sample-1 sample-locker)
    )
  )
)
