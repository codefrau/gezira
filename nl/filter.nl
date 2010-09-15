SumWeightedColors (n : Real) : (Color, Real) >> Color
    sum = 0 : Color
    i   = 1
    ∀ ((a, r, g, b), w)
        C = (a, r / (a ? 1), g / (a ? 1), b / (a ? 1)) : Color
        if i = n
            S = 0 ▷ (sum + C × w) ◁ 1
            >> (S.a, S.a × S.r, S.a × S.g, S.a × S.b)
            sum' = 0
            i'   = 1
        else
            sum' = sum + C × w
            i'   = i + 1

BilinearFilterPoints : Point >> Point
    ∀ P
        S = ⌊ P - 0.5 ⌋ + 0.5
        x = S.x
        y = S.y
        >> (x, y    ) >> (x + 1, y    )
        >> (x, y + 1) >> (x + 1, y + 1)

BilinearFilterWeights : Point >> Real
    ∀ P 
        S = P - ⌊ P - 0.5 ⌋ - 0.5
        u = S.x
        v = S.y
        >> (1 - u) × (1 - v) >> u × (1 - v)
        >> (1 - u) × (    v) >> u × (    v)

BilinearFilter (s : Sampler) : Sampler
    ⇒ Interleave (BilinearFilterPoints → s,
                  BilinearFilterWeights    ) → SumWeightedColors (4)

BicubicFilterWeights : Point >> Real
    ∀ D
        T = |D|
        S = {  1.5 × T × T × T - 2.5 × T × T + 1           if T < 1,
              -0.5 × T × T × T + 2.5 × T × T - 4 × T + 2   if T < 2,
                 0                                                  }
        >> S.x × S.y

BicubicFilterPoints : Point >> Point
    ∀ P
        S = ⌊ P - 0.5 ⌋ + 0.5
        x = S.x
        y = S.y
        >> (x-1, y-1) >> (x, y-1) >> (x+1, y-1) >> (x+2, y-1)
        >> (x-1, y  ) >> (x, y  ) >> (x+1, y  ) >> (x+2, y  )
        >> (x-1, y+1) >> (x, y+1) >> (x+1, y+1) >> (x+2, y+1)
        >> (x-1, y+2) >> (x, y+2) >> (x+1, y+2) >> (x+2, y+2)

BicubicFilterDeltas : Point >> Point
    ∀ P 
        S = ⌊ P - 0.5 ⌋ + 0.5
        x = S.x
        y = S.y
        >> (x-1, y-1) - P >> (x, y-1) - P >> (x+1, y-1) - P >> (x+2, y-1) - P
        >> (x-1, y  ) - P >> (x, y  ) - P >> (x+1, y  ) - P >> (x+2, y  ) - P
        >> (x-1, y+1) - P >> (x, y+1) - P >> (x+1, y+1) - P >> (x+2, y+1) - P
        >> (x-1, y+2) - P >> (x, y+2) - P >> (x+1, y+2) - P >> (x+2, y+2) - P

BicubicFilter (s : Sampler) : Sampler
    ⇒ Interleave (BicubicFilterPoints → s,
                  BicubicFilterDeltas → BicubicFilterWeights) → SumWeightedColors (16)

GaussianBlur21x1Points : Point >> Point
    ∀ (x, y)
        >> (x-10, y) >> (x-9, y) >> (x-8, y) >> (x-7, y) >> (x-6 , y)
        >> (x-5 , y) >> (x-4, y) >> (x-3, y) >> (x-2, y) >> (x-1 , y)
        >> (x   , y)
        >> (x+1 , y) >> (x+2, y) >> (x+3, y) >> (x+4, y) >> (x+5 , y)
        >> (x+6 , y) >> (x+7, y) >> (x+8, y) >> (x+9, y) >> (x+10, y)

GaussianBlur1x21Points : Point >> Point
    ∀ (x, y)
        >> (x, y-10) >> (x, y-9) >> (x, y-8) >> (x, y-7) >> (x, y-6 )
        >> (x, y-5 ) >> (x, y-4) >> (x, y-3) >> (x, y-2) >> (x, y-1 )
        >> (x, y   )
        >> (x, y+1 ) >> (x, y+2) >> (x, y+3) >> (x, y+4) >> (x, y+5 )
        >> (x, y+6 ) >> (x, y+7) >> (x, y+8) >> (x, y+9) >> (x, y+10)

GaussianBlur21x1Weights (f : Real) : Point >> Real
    a = 1048576 × f
    s = 1048576 + 21 × a
    ∀ _
        >> ((a +      1) / s) >> ((a +     20) / s) >> ((a +    190) / s)
        >> ((a +   1140) / s) >> ((a +   4845) / s) >> ((a +  15504) / s)
        >> ((a +  38760) / s) >> ((a +  77520) / s) >> ((a + 125970) / s)
        >> ((a + 167960) / s) >> ((a + 184756) / s) >> ((a + 167960) / s)
        >> ((a + 125970) / s) >> ((a +  77520) / s) >> ((a +  38760) / s)
        >> ((a +  15504) / s) >> ((a +   4845) / s) >> ((a +   1140) / s)
        >> ((a +    190) / s) >> ((a +     20) / s) >> ((a +      1) / s)

GaussianBlur21x1 (a : Real, s : Sampler) : Sampler
    ⇒ Interleave (GaussianBlur21x1Points → s,
                  GaussianBlur21x1Weights (a)) → SumWeightedColors (21)

GaussianBlur1x21 (a : Real, s : Sampler) : Sampler
    ⇒ Interleave (GaussianBlur1x21Points → s,
                  GaussianBlur21x1Weights (a)) → SumWeightedColors (21)
