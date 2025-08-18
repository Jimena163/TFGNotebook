module JIVECore

# -------- COMMON PACKAGES
# JuliaImages
# using Images
# Test Images
using TestImages

# using Graphics
# using Colors, Cairo

# -------- SUBMODULES
# Data analysis
include("analyze/Analyze.jl")
# Data structures
include("data/Data.jl")
# Image editing
# include("draw/Draw.jl")
# File handling
include("files/Files.jl")
# Image processing
include("process/Process.jl")
# Image visualization
include("visualize/Visualize.jl")


export Analyze, Data, Draw, Files, Process, Visualize
end
