module Files

# -------- GLOBAL CONSTANTS
const SUPPORTED_IMAGE_FORMATS = "png,tif,tiff;jpg,jpeg;bmp;gif" # Note: extensions must not contain dots (*.) and cannot separeted by spaces.
const SUPPORTED_VIDEO_FORMATS = "mp4" # Note: extensions must not contain dots (*.) and cannot separeted by spaces.

# IO backends
using FileIO, ImageMagick, ImageIO, VideoIO
# File dialogs
import NativeFileDialog as Dialog # maybe we may have to add Gtk4.jl or Mousetrap.jl
# other imports
using Images: imresize

# Import Data module to access its functions
using ..Data

include("Input.jl")
include("Output.jl")
include("utils.jl")

# Input
export loadImage, loadVideo, loadSequence, loadClipboard, loadImage!, loadNextImage, loadPreviousImage
# Output
export saveImage, saveImageTemp

end






