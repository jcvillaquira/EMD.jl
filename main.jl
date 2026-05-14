using Plots
using Revise
using Debugger

includet("src/EMD_IF.jl")
Revise.track(EMD_IF, "src/dataholders.jl")
Revise.track(EMD_IF, "src/model.jl")
Revise.track(EMD_IF, "src/emd.jl")
Revise.track(EMD_IF, "src/if.jl")
using .EMD_IF

N = 200
jmp = 2
f = jmp * Float64.(1:N .> N/4) .+ 2jmp * Float64.(1:N .> 2N/4) .+ 3jmp * Float64.(1:N .> 3N/4) .+ 4jmp * Float64.(1:N .> 4N/4) + rand(N)
plot(f)

model = Model(copy(f); algorithm = :IF)
sifting!(model)
plot_modes(model)

