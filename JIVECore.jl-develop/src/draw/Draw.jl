module Draw

using ..Graphics
using ..Colors, ..Cairo

# --------- Common packages
using ..Images, ..TestImages

using FileIO
using Base64
using PNGFiles
using PlotlyJS; export PlotlyJS

include("utils.jl")
export draw_shape

end