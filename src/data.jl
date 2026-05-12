module EMD


using Dierckx


export DataHolder
export update_extrema!


struct DataHolder
  f::Vector
  minima::BitArray
  maxima::BitArray
end


function DataHolder(f::Vector)
  minima = similar(BitArray, length(f))
  maxima = similar(BitArray, length(f))
  minima[1] = true
  minima[end] = true
  maxima[1] = true
  maxima[end] = true
  return DataHolder(f, minima, maxima)
end


Base.length(dh::DataHolder) = length(dh.f)


function update_extrema!(dh::DataHolder)
  prev, curr = dh.f[1], dh.f[2]
  for j in 2:(length(dh)-1)
    nxt = dh.f[j+1]
    dh.minima[j] = ( prev > curr ) && ( curr < nxt )
    dh.maxima[j] = ( prev < curr ) && ( curr > nxt )
    prev = curr
    curr = nxt
  end
end


end
