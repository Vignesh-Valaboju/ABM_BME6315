globals [
  sample-car
  clock
]
breed [plaques plaque]
breed [cells cell]

turtles-own [
  speed
  speed-limit
  speed-min
]

to setup
  clear-all
  ask patches [ setup-vessel ]
  setup-cars
  setup-plaque
  reset-ticks
end

to setup-vessel ;; patch procedure
  if pycor < 2.5 and pycor > -2.5 [ set pcolor red ]
  if pycor < -2.5 or pycor > 2.5 [ set pcolor black ]
end

to setup-plaque
  set-default-shape cells "square"
  create-plaques 1 [
    set color yellow
    set xcor 0
    set ycor -2.5
  ]
end


to setup-cars
  if number-of-cars > world-width [
    user-message (word
      "There are too many cars for the amount of road. "
      "Please decrease the NUMBER-OF-CARS slider to below "
      (world-width + 1) " and press the SETUP button again. "
      "The setup has stopped.")
    stop
  ]
  set-default-shape cells "circle"
  create-cells number-of-cars [
    set color red - 2
    set xcor -25
    set ycor -2.5 + random-float 5
    set heading 90
    ;; set initial speed to be in range 0.1 to 1.0
    set speed 0 + random-float 1.0
    set speed-limit 1
    set speed-min 0
    separate-cars
  ]
end


; this procedure is needed so when we click "Setup" we
; don't end up with any two cars on the same patch
to separate-cars ;; turtle procedure
  if any? other cells-here [
    fd 1
    separate-cars
  ]
end

to go
  ;; if there is a car right ahead of you, match its speed then slow down
  ask cells [
    let car-ahead one-of cells-on patch-ahead 1
    let plaque-ahead one-of plaques-on patch-ahead 1
    ifelse car-ahead != nobody
      [ slow-down-car car-ahead ]
      [ speed-up-car ] ;; otherwise, speed up
    ifelse plaque-ahead != nobody
      [  set heading heading - 10 ]
      [ speed-up-car 
      set heading 90
      ] ;; otherwise, speed up
    ifelse car-ahead != nobody
      [ slow-down-car car-ahead ]
      [ speed-up-car ] ;; otherwise, speed up
    ;; don't slow down below speed minimum or speed up beyond speed limit
    if speed < speed-min [ set speed speed-min ]
    if speed > speed-limit [ set speed speed-limit ]

    fd speed
  ]
  set clock clock + 1
  if clock mod 30 = 0 [form-plaque]
  tick
end

to form-plaque
    ask plaques [hatch 1 [right random 360 fd 1]]
end



to slow-down-car [ car-ahead ] ;; turtle procedure
  ;; slow down so you are driving more slowly than the car ahead of you
  set speed [ speed ] of car-ahead - deceleration
end


to speed-up-car ;; turtle procedure
  set speed speed + acceleration
end

; Copyright 1997 Uri Wilensky.
; See Info tab for full copyright and license.
