abstract type DataHolder end


function stop!(data::DataHolder)
  return false
end


Base.length(data::DataHolder) = length(data.f)


## DataHolder for Empirical Mode Decomposition


mutable struct DataHolderEMD{N} <: DataHolder
  f::Vector
  minima::BitVector       
  maxima::BitVector
  iter::Int
  stop::Bool
end


function DataHolderEMD(f::Vector; N::Int = 3)
  if ( N != 1 ) && ( N != 3 )
    throw("N must be either 1 or 3")
  end
  minima = similar(BitVector, length(f))
  maxima = similar(BitVector, length(f))
  return DataHolderEMD{N}(f, minima, maxima, 0, false)
end


## DataHolder for Iterative Filtering


mutable struct DataHolderIF <: DataHolder
  f::Vector
  iter::Int
  stop::Bool
end


function DataHolderIF(f::Vector)
  return DataHolderIF(f, 0, false)
end

