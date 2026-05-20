using Interpolations
using Statistics

mutable struct JModel
  model::Model
  jump::Vector
  height::Float64
end


function JModel(model)
  jump = similar(model.residue)
  return JModel(model, jump, 0.0)
end


function compute_jump_height!(jmodel)
  update_extrema!(jmodel.model.data)
  idx_min = findall(jmodel.model.data.minima)
  idx_max = findall(jmodel.model.data.maxima)
  spl_min = linear_interpolation(idx_min, jmodel.model.data.f[idx_min])
  spl_max = linear_interpolation(idx_max, jmodel.model.data.f[idx_max])
  rg = collect(1:length(jmodel.model))
  height = spl_max(rg) .- spl_min(rg)
  jmodel.height = 2.0 * quantile(height, 0.5)
end


function compute_jump_function!(jmodel)
  k = sum(jmodel.model.data.minima .|| jmodel.model.data.maxima)
  mp = 1 + Int(ceil( 2 * k / length(jmodel.model) ))
  # Compute biased averages
  mleft = similar(jmodel.model.residue)
  mright = similar(mleft)
  for j in eachindex(mleft)
    mleft[j] = mright[j] = 0.0
    if ( j - mp < 1 ) || ( j + mp > length(jmodel.model) )
      continue
    end
    for mm in 1:mp
      mleft[j] += jmodel.model.residue[j-mm] / ( mp  )
      mright[j] += jmodel.model.residue[j+mm] / ( mp )
    end
  end
  # Compute candidates to jumps
  absdiff = @. abs( mright - mleft )
  amodel = Model(absdiff)
  update_extrema!(amodel.data)
  idx = sort(findall(amodel.data.maxima); by = j -> absdiff[j], rev = true)
  real_idx = similar(idx, 0)
  for i in idx
    if abs(mleft[i] - mright[i]) < jmodel.height
      break
    end
    push!(real_idx, i)
  end
  # Correct jump position
  idx2 = similar(real_idx)
  for (j, i) in enumerate(real_idx)
    ii = i
    jmp = -Inf
    for mm in (-mp):mp
      if ( i + mm - 1 < 1 ) || ( i + mm + 1 > length(jmodel.model) )
        continue
      end
      current_jmp = abs( jmodel.model.residue[i+mm+1] - jmodel.model.residue[i+mm] )
      if current_jmp > jmp
        jmp = current_jmp
        ii = i + mm
      end
    end
    idx2[j] = ii 
  end
  # Compute jump function 
  jmodel.jump .= 0.0
  for j in idx2
    for jj in (j+1):length(jmodel.model)
      jmodel.jump[jj] += mright[j] - mleft[j]
    end
  end
end


function substract_jump_function!(jmodel)
  jmodel.model.data.f .-= jmodel.jump
  jmodel.model.residue .-= jmodel.jump
end

function run!(jmodel::JModel)
  compute_jump_height!(jmodel)
  compute_jump_function!(jmodel)
  substract_jump_function!(jmodel)
  sifting!(jmodel.model)
end

function plot_modes(jmodel::JModel)
  # TODO: Avoid allocations here.
  pl = plot_modes(jmodel.model; with_jump = true)
  original = sum(jmodel.model.modes) .+ jmodel.model.residue .+ jmodel.jump
  plot!(pl, original, subplot = 1, linecolor = "red")
  plot!(pl, jmodel.jump, subplot = 2)
  return pl
end

