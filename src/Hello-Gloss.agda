
-- On Ubuntu 22.04.1, I also had to
-- apt install libghc-glut-dev

module Hello-Gloss where

open import Agda.Builtin.Float
open import Agda.Builtin.IO
open import Agda.Builtin.Unit

{-# FOREIGN GHC import Graphics.Gloss #-}
{-# FOREIGN GHC import GHC.Float #-}

postulate
    Color : Set
    red : Color
    green : Color
    blue : Color
    white : Color
{-# COMPILE GHC Color = type Color #-}
{-# COMPILE GHC red = red #-}
{-# COMPILE GHC green = green #-}
{-# COMPILE GHC blue = blue #-}
{-# COMPILE GHC white = white #-}
postulate
    Picture : Set
    color : Color → Picture → Picture
    rectangleSolid : Float → Float → Picture
    rotate : Float → Picture → Picture
{-# COMPILE GHC Picture = type Picture #-}
{-# COMPILE GHC color = color #-}
{-# COMPILE GHC rectangleSolid = \x y -> rectangleSolid (double2Float x) (double2Float y) #-}
{-# COMPILE GHC rotate = rotate . double2Float #-}
postulate
    Display : Set
    FullScreen : Display
    display : Display → Color → Picture → IO ⊤
    animate : Display → Color → (Float → Picture) → IO ⊤
{-# COMPILE GHC Display = type Display #-}
{-# COMPILE GHC FullScreen = FullScreen #-}
{-# COMPILE GHC display = display #-}
{-# COMPILE GHC animate = \d c f -> animate d c (f . float2Double) #-}

main : IO ⊤
main = animate FullScreen green λ t →
    rotate t (
        color blue (
            rectangleSolid 15.0 200.0
        )
    )
