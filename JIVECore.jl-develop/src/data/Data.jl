module Data

# -------- Image data dictionary
image_data = Dict{String, Any}()
image_keys = String[]

include("Types.jl")
export convertImage, im2float, im2gray, im2rgb, im2hsv, im2separate, im2norm, im2raw,  im2stack, seq2stack
include("Transformations.jl")
export imMatching
include("Metadata.jl")
export imageProperties, showInfo
include("Morphology.jl")

include("Multidimensional.jl")

include("utils.jl")

export image_data, image_keys

end