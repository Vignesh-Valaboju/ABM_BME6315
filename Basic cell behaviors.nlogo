globals
[
  generations          ; counts how many generations have passed
  red-count            ; population of red turtles
  clock
  number-of-cells
  diffusioncoeff
  amountVEGFug
  diffusionclock
  VEGFxsource
  VEGFysource

]

breed [ endothelial endothelials ]
breed [ singlesource singlesources ]
breed [ source sources ]
breed [ linesource linesources ]
breed [ ECMturtle ECMturtles ]


endothelial-own
[
VEGF-R1
]

source-own
[
turtleVEGF
]

linesource-own
[
turtlePDGF
]

patches-own
[
collagen
VEGFxcord
VEGFycord
patchVEGF
patchPDGF
patchdist ;distance from a particular patch to the source
VEGFcoeff
VEGFexp
VEGF
]

to setup
  ca
  set generations 0
  set diffusionclock 0
  crt initial-cells
  [
    setxy (random-float world-width)
          (random-float world-height)    ; randomize turtle locations
    ;set color red

    set breed endothelial
  ]
  ask endothelial [set shape "endothelial"]
end

to go
  if clock mod 2 = 0 [migrate]
  if clock mod 5 = 0 [proliferate]
  apoptose
  set clock clock + 1
end

to migrate
  ask turtles
  [
    ; pd
    rt random-float 30 lt random-float 30
    fd 1
  ]
end


to proliferate
  ask endothelial [hatch 1 [right random 360 fd 1]]
  set generations generations + 1
  set number-of-cells count endothelial
end

to apoptose
  ask turtles [if sum [count turtles-here] of neighbors > apopthresh [die]]
end

to differentiate
 if clock mod 3 = 0
 [ask endothelial [if sum [count turtles-here] of neighbors > diffthresh [set VEGF-R1 45]]]
 ask endothelial [if VEGF-R1 = 45 [set shape "VEGFEC"]]
end

; DIFFUSION OF FACTORS

;~~~~~~~~~~~~~~~~ Single Point Source ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

to draw-red
if mouse-down? [
                  ask patch mouse-xcor mouse-ycor [ set pcolor red]
                   ask patches [set VEGFxcord mouse-xcor set VEGFycord mouse-ycor]
                  ]

;   if mouse-down? [
;                   set [pcolor] of (patch-at mouse-xcor mouse-ycor) red
;                   ask patches [set VEGFxcord mouse-xcor set VEGFycord mouse-ycor]
;                  ]
   ;If the mousebutton is depressed, this subroutine sets the patch color of the patch
   ;immediately underneath the mouse cursor to white.  Use this to mark your point sources.
end

to laydownsource
   ask patches [if pcolor = red [sprout 1 [set breed singlesource]]]
   ask patches [set VEGFxsource VEGFxcord set VEGFysource VEGFycord]
   set diffusionclock 1
end

to diffuse-single-VEGF
   set diffusioncoeff (.0000000005)
   set amountVEGFug (.00033)
   ask patches [
                set patchdist ((round (distancexy-nowrap VEGFxsource VEGFysource)) / 1000)
                set VEGFcoeff ((amountVEGFug / (4 * pi * diffusioncoeff * diffusionclock * 3600)))
                set VEGFexp (0 - ((patchdist ^ 2) / (4 * diffusioncoeff * diffusionclock * 3600)))
                set VEGF (VEGFcoeff * (e ^ (VEGFexp)))
                set pcolor scale-color gray VEGF .0001 1
               ]
   set diffusionclock (diffusionclock + 1)
end

;~~~~~~~~~~~~~~~~ Multiple Point Sources ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
to draw-white
  if mouse-down? [
                  ask patch mouse-xcor mouse-ycor [ set pcolor white]
                   ask patches [set VEGFxcord mouse-xcor set VEGFycord mouse-ycor]
                  ]

  ; if mouse-down? [
  ;                 set [pcolor] of (patch-at mouse-xcor mouse-ycor) white
  ;                ]
   ;If the mousebutton is depressed, this subroutine sets the patch color of the patch
   ;immediately underneath the mouse cursor to white.  Use this to mark your point sources.
end

to laydownsources
   ask patches [if pcolor = white [sprout 1 [set breed source]]]
   ask source [set turtleVEGF 2000 set patchVEGF turtleVEGF]
end

to diffuse-noturt-VEGF
  ask patches [if pcolor = white [ set patchVEGF 1000 ]]
  diffuse patchVEGF .05
  ask patches [set pcolor scale-color gray patchVEGF 0 10]
end

;to diffuse-VEGF
; diffuse patchVEGF .1
; ask patches [set pcolor scale-color gray patchVEGF 1 40]
;end


;~~~~~~~~~~~~~~~ Line Source ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

to draw-green
  if mouse-down? [
                  ask patch mouse-xcor mouse-ycor [ set pcolor green ]
                   ask patches [set VEGFxcord mouse-xcor set VEGFycord mouse-ycor]
                  ]
  ; if mouse-down? [
  ;                 set [pcolor] of (patch-at mouse-xcor mouse-ycor) green
  ;                ]
end

to laydownlinesources
   ask patches [if pcolor = green [sprout 1 [set breed linesource]]]
   ask linesource [set turtlePDGF 500 set patchPDGF turtlePDGF]
end

to diffuse-PDGF
  diffuse patchPDGF .005            ; this causes the "spreading" of heat
  ask patches [set pcolor scale-color pink patchPDGF 1 40]
end


; ECM

to laydown-ECM
crt 1 [set breed ECMturtle set pcolor orange repeat 65 [pd set color green fd 1 set pcolor orange rt random 90 lt random 90 fd 1 set pcolor orange]]
ask patches [if pcolor = orange [set collagen 20]]
end

to sense-ECM
ask endothelial [if [pcolor] of patch-at 0 0 = orange [set shape "star" set color yellow set size 2]]
end
@#$#@#$#@
GRAPHICS-WINDOW
478
10
925
458
-1
-1
13.303030303030303
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
26
69
179
102
initial-cells
initial-cells
0
100
48.0
1
1
NIL
HORIZONTAL

BUTTON
28
27
94
60
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
106
27
169
60
NIL
Go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
30
207
109
240
NIL
migrate
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
29
274
125
307
NIL
proliferate
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
33
603
145
636
NIL
differentiate
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
29
333
118
366
NIL
apoptose
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
30
164
168
197
Migration trail on
ask endothelial [pd]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
173
164
325
197
Migration trail off
ask endothelial [pu]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
276
29
402
74
# Endothelial Cells
count endothelial
17
1
11

MONITOR
278
81
366
126
Generations
generations
17
1
11

SLIDER
129
332
234
365
apopthresh
apopthresh
0
10
8.0
1
1
NIL
HORIZONTAL

BUTTON
29
390
179
423
Place VEGF Sources
draw-white
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
29
430
179
463
Diffuse VEGF
diffuse-noturt-VEGF
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
537
466
653
499
NIL
laydown-ECM
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
539
506
654
539
NIL
sense-ECM\n\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
151
602
243
635
diffthresh
diffthresh
0
5
5.0
1
1
NIL
HORIZONTAL

BUTTON
226
209
344
242
NIL
clear-drawing
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
31
469
219
502
migrate up VEGF gradient
uphill patchVEGF\nleft random-float 180 right random-float 180 fd 1\nleft random-float 180 right random-float 180 fd 1\nleft random-float 180 right random-float 180 fd 1
NIL
1
T
TURTLE
NIL
NIL
NIL
NIL
1

BUTTON
31
509
189
542
make three "fish" shaped
ask n-of 3 endothelial [ \nset size 2 \nset shape \"fish\" \nset patchvegf 500]\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
31
549
187
582
let fish secrete VEGF
diffuse patchVEGF .05\nask patches [set pcolor scale-color gray patchVEGF 0 10]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
252
590
648
655
threshold for differentiation based on the number of neighboring cells (a smaller threshold means the cell will differentiate if it has fewer neighbors, while a larger threshold means there need to be more neighbors for the cell to differentiate
11
0.0
1

TEXTBOX
116
219
266
237
Make cells migrate
11
0.0
1

TEXTBOX
131
285
281
303
Make cells proliferate
11
0.0
1

TEXTBOX
244
339
468
387
Make cells die if they are too crowded (slider sets crowding tolerance)
11
0.0
1

TEXTBOX
188
393
338
421
draw sources of diffusible factors with your mouse
11
0.0
1

TEXTBOX
188
431
338
459
diffuse factor from the mouse-drawn souces
11
0.0
1

TEXTBOX
225
469
486
511
cells migrate (somewhat directed, somewhat random) up the gradient of the diffusible factor
11
0.0
1

TEXTBOX
195
511
427
567
randomly pick 3 cells and turn them into fish and secrete VEGF into the environment
11
0.0
1

TEXTBOX
194
551
380
579
diffuse VEGF into the world from the fish sources
11
0.0
1

TEXTBOX
661
468
876
530
Create new cells and have them migrate and make ECM in their trail
11
0.0
1

TEXTBOX
661
507
912
537
Cells check to see if they are on ECM, and if they are they change their shape and size.
11
0.0
1

BUTTON
183
27
266
60
Clear All
ca
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

endothelial
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

vegfec
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
