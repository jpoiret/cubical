{-# OPTIONS --safe #-}
module Cubical.Algebra.NatSolver.Examples where

open import Cubical.Foundations.Prelude

open import Cubical.Data.FinData
open import Cubical.Data.Nat
open import Cubical.Data.Vec.Base

open import Cubical.Algebra.NatSolver.NatExpression
open import Cubical.Algebra.NatSolver.HornerForms
open import Cubical.Algebra.NatSolver.Solver
open import Cubical.Algebra.NatSolver.Reflection

private
  variable
    ℓ : Level

module ReflectionSolving where
  _ : (x y : ℕ) → (x + y) · (x + y) ≡ x · x + 2 · x · y + y · y
  _ = solve

module SolvingExplained where
  open EqualityToNormalform renaming (solve to natSolve)
  open IteratedHornerOperations hiding (X)

  ℕ[X₀,X₁] = IteratedHornerForms 2
  X₀ : ℕ[X₀,X₁]
  X₀ = Variable 2 (Fin.zero)

  X₁ : ℕ[X₀,X₁]
  X₁ = Variable 2 (suc Fin.zero)

  Two : ℕ[X₀,X₁]
  Two = Constant 2 2

  _ : eval 2 X₀ (1 ∷ 0 ∷ []) ≡ 1
  _ = refl

  _ : eval 2 X₁ (0 ∷ 1 ∷ []) ≡ 1
  _ = refl

  X : Expr 3
  X = ∣ Fin.zero

  Y : Expr 3
  Y = ∣ (suc Fin.zero)

  Z : Expr 3
  Z = ∣ (suc (suc Fin.zero))

  {-
     'normalize' maps an expression to its Horner Normalform.
     Two expressions evaluating to the same ring element
     have the same Horner Normal form.
     This means equality of the represented ring elements
     can be checked by agda's unification (so refl is a proof)

   -}
  _ : normalize 3 ((K 2) ·' X) ≡
      normalize 3 (X +' X)
  _ = refl


  _ : normalize 3 ((K 2) ·' X) ≡ normalize 3 (X +' X)
  _ = refl

  _ : normalize 3 (((K 2) ·' X) ·' Y) ≡ normalize 3 (Y ·' (X +' X))
  _ = refl

  _ : normalize 3 (Z ·' (((K 2) ·' X) ·' Y)) ≡ normalize 3 (Z ·' (Y ·' (X +' X)))
  _ = refl


  {-
    The solver needs to produce an equality between
    actual ring elements. So we need a proof that
    those actual ring elements are equal to a normal form:
  -}
  _ : (x y z : ℕ) →
      eval 3 (normalize 3 ((K 2) ·' X ·' Y)) (x ∷ y ∷ z ∷ [])
      ≡ 2 · x · y
  _ = λ x y z → isEqualToNormalform 3 ((K 2) ·' X ·' Y) (x ∷ y ∷ z ∷ [])

  {-
    Now two of these proofs can be plugged together
    to solve an equation:
  -}
  open Eval
  _ : (x y z : ℕ) → 3 + x + y · y ≡ y · y + x + 1 + 2
  _ = let
        lhs = (K 3) +' X +' (Y ·' Y)
        rhs = Y ·' Y +' X +' (K 1) +' (K 2)
      in (λ x y z →
          ⟦ lhs ⟧ (x ∷ y ∷ z ∷ [])
        ≡⟨ sym (isEqualToNormalform 3 lhs (x ∷ y ∷ z ∷ [])) ⟩
          eval 3 (normalize 3 lhs) (x ∷ y ∷ z ∷ [])
        ≡⟨ refl ⟩
          eval 3 (normalize 3 rhs) (x ∷ y ∷ z ∷ [])
        ≡⟨ isEqualToNormalform 3 rhs (x ∷ y ∷ z ∷ []) ⟩
          ⟦ rhs ⟧ (x ∷ y ∷ z ∷ []) ∎)

  {-
    Parts of that can be automated easily:
  -}
  _ : (x y z : ℕ) → (x + y) · (x + y) ≡ x · x + 2 · x · y + y · y
  _ = λ x y z → let
              lhs = (X +' Y) ·' (X +' Y)
              rhs = X ·' X +' (K 2) ·' X ·' Y +' Y ·' Y
             in natSolve lhs rhs (x ∷ y ∷ z ∷ []) refl

  {-
    A bigger example
  -}
  _ : (x y z : ℕ) → (x + y) · (x + y) · (x + y) · (x + y)
                ≡ x · x · x · x + 4 · x · x · x · y + 6 · x · x · y · y
                  +  4 · x · y · y · y + y · y · y · y
  _ = λ x y z → let
              lhs = (X +' Y) ·' (X +' Y) ·' (X +' Y) ·' (X +' Y)
              rhs = X ·' X ·' X ·' X
                  +' (K 4) ·' X ·' X ·' X ·' Y
                  +' (K 6) ·' X ·' X ·' Y ·' Y
                  +' (K 4) ·' X ·' Y ·' Y ·' Y
                  +' Y ·' Y ·' Y ·' Y
             in natSolve lhs rhs (x ∷ y ∷ z ∷ []) refl
  {-
    this one cannot work so far:

  _ : (x y z : ℕ) → (x + y) · (x - y) ≡ (x · x - (y · y))
  _ = λ x y z → let
                lhs = (X +' Y) ·' (X +' (-' Y))
                rhs = (X ·' X) +' (-' (Y ·' Y))
              in natSolve lhs rhs (x ∷ y ∷ z ∷ []) {!!}
  -}
