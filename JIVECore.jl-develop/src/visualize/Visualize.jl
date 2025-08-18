module Visualize

# ImageShow
using ImageShow, ImageView
using Colors

# FileIO
using FileIO

# --------- Common packages
using Images: mosaicview
# using ..Images
# using ..Graphics
# using ..Colors, ..Cairo

# Import Draw module to access its functions
# using ..Draw

include("utils.jl")
export mosaicview, imageWindow, channelView, gif

end