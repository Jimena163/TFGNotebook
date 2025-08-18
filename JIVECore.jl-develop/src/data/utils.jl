using Images: pixelspacing, spacedirections, sdims, coords_spatial, size_spatial, indices_spatial, nimages, timeaxis, istimeaxis, timedim, assert_timedim_last

function keyCheck(dict::Dict, key::String)
    if haskey(dict, key)
        if isNumber(key[end])
            return keyCheck(dict, key[1:end-1] * (key[end] + 1))
        else
            return keyCheck(dict, key * "_1")
        end 
    else    
        return key
    end 
end

function isNumber(caracter::Char)
    try
        parse(Int, caracter)
        return true
    catch e
        return false
    end
end

function maxDims(matrices::Tuple)
    num_dims = maximum(map(ndims, matrices))
    max_sizes = [maximum(map(size, matrices)) do s
        if i <= length(s)
            s[i]
        else
            1
        end
    end for i in 1:num_dims]
    return tuple(max_sizes...)
end

function minDims(matrices::Tuple)
    num_dims = minimum(map(ndims, matrices))
    min_sizes = [minimum(map(size, matrices)) do s
        if i <= length(s)
            s[i]
        else
            1
        end
    end for i in 1:num_dims]
    return tuple(min_sizes...)
end
