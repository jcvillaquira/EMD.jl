using Plots
using Revise
using Debugger
using CSV

includet("src/EMD_IF.jl")
Revise.track(EMD_IF, "src/dataholders.jl")
Revise.track(EMD_IF, "src/model.jl")
Revise.track(EMD_IF, "src/emd.jl")
Revise.track(EMD_IF, "src/if.jl")
Revise.track(EMD_IF, "src/jmodel.jl")
using .EMD_IF

## STEP 0: Load data
f = CSV.File(open("data/example.csv"), header=false).Column1
N = length(f)

## Create Model
model = Model(copy(f), algorithm = :IF)
sifting!(model)
plot_modes(model)

## Create JModel
model = Model(copy(f), algorithm = :IF)
jmodel = JModel(model)
run!(jmodel)
plot_modes(jmodel)

