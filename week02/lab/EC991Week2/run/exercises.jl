# EC991 Week 2 exercises
# Run from week02/lab/EC991Week2 with:
#   julia --project=. run/exercises.jl

using EC991Week2
using Printf

println("Exercise 1: patience (beta * R = 1)")
patient = Household(β = 1 / 1.03)
a_patient = asset_grid(patient; amax = 3.0, na = 1000)
sol_patient = solve_vfi(patient, a_patient; tol = 1e-7)
assets_patient, consumption_patient = simulate(sol_patient, 2.5, 200)
policy_gap = maximum(abs.(sol_patient.apol .- sol_patient.a))
@printf("  beta*R = %.6f; a0 = %.3f; a200 = %.3f\n",
        patient.β * patient.R, assets_patient[1], assets_patient[end])
@printf("  max |a'(a)-a| on the grid = %.6f\n", policy_gap)
println("  Interpretation: beta*R = 1 removes the systematic consumption-growth")
println("  force. Away from binding/truncation points, the saving policy lies close")
println("  to the 45-degree line, so assets have little systematic drift.")

println("\nExercise 2: grid coarseness")
baseline = Household()
for na in (50, 1000)
    a = asset_grid(baseline; amax = 3.0, na = na)
    sol = solve_vfi(baseline, a; tol = 1e-7)
    assets, consumption = simulate(sol, 2.5, 200)
    residuals = euler_residuals(consumption, baseline)
    first_binding = findfirst(t -> assets[t + 1] == a[1], 1:200)
    slack_end = isnothing(first_binding) ? length(residuals) : max(first_binding - 1, 1)
    @printf("  na = %4d; grid step = %.6f; max |Euler residual| before binding = %.6g\n",
            na, a[2] - a[1], maximum(abs.(residuals[1:slack_end])))
end
println("  Interpretation: the finer grid restricts choices less severely, so the")
println("  consumption function is smoother and the pre-constraint Euler error falls.")
println("  With a uniform grid, the discretisation error should fall roughly with the")
println("  grid spacing, although policy jumps prevent an exact rate in every state.")

println("\nExercise 3: bequest motive")
T = 60
y_lifecycle = life_cycle_income(T)
a_lifecycle = asset_grid(baseline; amax = 15.0, na = 600)
for phi_b in (0.0, 0.5, 1.0, 2.0)
    terminal = phi_b .* utility.(a_lifecycle .+ baseline.φ, Ref(baseline))
    finite = solve_backward(baseline, a_lifecycle, y_lifecycle; terminal = terminal)
    assets, _ = simulate_finite(finite, 0.0)
    @printf("  phi_b = %.1f; terminal wealth = %.4f\n", phi_b, assets[end])
end
println("  Interpretation: a stronger bequest motive raises the marginal value of")
println("  terminal assets and therefore raises terminal wealth (up to grid effects).")

println("\nExercise 4: timing")
println("  Timings include one warm-up solve, then the measured solve.")
for na in (100, 300, 1000)
    a = asset_grid(baseline; amax = 3.0, na = na)
    solve_vfi(baseline, a; tol = 1e-6)
    elapsed = @elapsed solve_vfi(baseline, a; tol = 1e-6)
    @printf("  na = %4d; elapsed = %.3f seconds\n", na, elapsed)
end
println("  Interpretation: each Bellman step compares every current-asset state with")
println("  every next-asset choice, so time should grow approximately with na^2.")
