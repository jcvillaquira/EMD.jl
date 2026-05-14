struct Model{D<:DataHolder}
  dh::D
  modes::Vector{Vector}
  residue::Vector
end


function Model(f::Vector; algorithm = :EMD)
  modes = Vector{Vector{eltype(f)}}()
  residue = copy(f)
  if algorithm === :EMD
    dh = DataHolderEMD(f)
    return Model{DataHolderEMD}(dh, modes, residue)
  end
  throw("Algorithm not recognized.")
end


Base.length(model::Model) = length(model.residue)


function sifting!(model::Model)
  for _ in 1:10
    sifting_step!(model)
    push!(model.modes, copy(model.dh.f))
    model.residue .-= model.dh.f
    model.dh.f .= model.residue
  end
end


function plot_modes(model::Model)
  n_modes = sum(any(m .!= 0) for m in model.modes)
  original = zeros(length(model))
  default(
      size = (1920, 1080),
      legend = false,
      lw = 2,
      margin = 1Plots.mm,
      left_margin = 2Plots.mm,
      bottom_margin = 1Plots.mm
  )
  pl = plot(layout = (n_modes + 2, 1));
  for n in 1:n_modes
    original .+= model.modes[n]
    plot!(pl, model.modes[n], subplot = n + 1)
  end
  original .+= model.residue
  plot!(pl, model.residue, subplot = n_modes + 2)
  plot!(pl, original, subplot = 1, linecolor = "red")
  return pl
end


