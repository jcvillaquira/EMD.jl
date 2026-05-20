
function compute_window_size!(data::DataHolderIF)
  k = sum(data.minima) + sum(data.maxima) - 2
  data.m = Int(floor( data.alpha * length(data) / k ))
end


function double_averaging!(data::DataHolderIF)
  for n in eachindex(data.mean)
    data.mean[n] = 0.0
    for j in (-data.m):data.m
      # a_j = ( data.m + 1 - abs(j) ) / ( data.m + 1 ) ^ 2
      a_j = 1.0 / ( 2 * data.m + 1 )
      idx = 1 + mod(n + j - 1, length(data))
      data.mean[n] += a_j * data.f[idx]
    end
  end
end


function sifting_step!(data::DataHolderIF)
  while !stop!(data)
    update_extrema!(data)
    compute_window_size!(data)
    double_averaging!(data)
    @. data.f -= data.mean
  end
end



function stop!(data::DataHolderIF)
  if data.stop || ( data.iter >= 10 )
    data.iter = 0
    data.stop = false
    return true
  end
  data.iter += 1
  return false
end

