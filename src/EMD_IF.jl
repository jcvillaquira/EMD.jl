module EMD_IF


export Model
export sifting!, plot_modes
export JModel
export run!


include("dataholders.jl")
include("model.jl")
include("emd.jl")
include("if.jl")
include("jmodel.jl")


end
