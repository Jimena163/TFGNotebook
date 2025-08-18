using Images: colorview, rawview, channelview, Gray, RGB, HSV, normedview, StackedView, AxisArray, Axis
using Colors: Colorant, ColorTypes

"""
    convertImage(input_image, conversion::String; bitrate::Int = 8)

Convert an image according to the specified conversion operation (:rgb, :gray, :bitrate, :stack, etc.).
"""
function convertImage(input_image::AbstractArray, conversion::Union{Symbol, String}; bitrate::Int = 8)
    conversion = Symbol(conversion)
    max_val = 2^bitrate - 1

    return conversion == :rgb      ? colorview(RGB, input_image) :
           conversion == :gray     ? Gray.(input_image) :
           conversion == :bitrate  ? (bitrate < 1 || bitrate > 64 && throw(ArgumentError("Bitrate must be between 1 and 64.")); round.(input_image .* max_val) ./ max_val) :
           conversion == :stack    ? channelview(input_image) :
           conversion == :separate ? separate_channels(input_image) :
           conversion == :hsv      ? (eltype(input_image) <: ColorTypes.RGB ? map(HSV, input_image) : throw(ArgumentError("Input image must be RGB for 'hsv' output."))) :
           conversion == :normed   ? normedview(input_image) :
           conversion == :raw      ? rawview(input_image) :
           throw(ArgumentError("Invalid output format. Use 'rgb', 'gray', 'bitrate', 'stack', 'separate', 'hsv', 'normed', or 'raw'."))
end

"""
    separate_channels(input_image)

Helper function to separate RGB or HSV channels into grayscale components.
"""
function separate_channels(input_image::AbstractArray)
    channels = channelview(input_image)
    eltype(input_image) <: ColorTypes.RGB ? (R = Gray.(channels[1, :, :]), G = Gray.(channels[2, :, :]), B = Gray.(channels[3, :, :])) :
    eltype(input_image) <: ColorTypes.HSV ? (H = Gray.(channels[1, :, :]), S = Gray.(channels[2, :, :]), V = Gray.(channels[3, :, :])) :
    throw(ArgumentError("Input image must be RGB or HSV for 'separate' output."))
end

"""
    im2axis(img::AbstractArray, args::Vararg{String, N})

Convert an image array to an `AxisArray` with specified axis labels.
"""
function im2axis(img::AbstractArray, args::Vararg{Union{String, Symbol}, N}) where N
    ndims(img) == length(args) || error("Number of axes must match the number of dimensions of the image")
    AxisArray(im2float(img), Symbol.(args)...)
end

"""
    im2float(input_image, precision::Symbol)

Convert the raw channel view of an image to the specified floating-point precision.
"""
function im2float(input_image::AbstractArray{<:Colorant}, precision::Symbol = :float32)
    raw_data = rawview(channelview(input_image))
    precision == :float32 ? Float32.(raw_data) :
    precision == :float64 ? Float64.(raw_data) :
    throw(ArgumentError("Invalid precision. Use :float32 or :float64."))
end

"""
    im2gray(input_image::AbstractArray{<:Colorant})

Convert an image to grayscale.
"""
im2gray(input_image::AbstractArray{<:Colorant}) = Gray.(input_image)

"""
    im2rgb(input_image::AbstractArray{<:Colorant})

Convert an image to RGB.
"""
im2rgb(input_image::AbstractArray{<:Colorant}) = colorview(RGB, input_image)

"""
    im2hsv(input_image::AbstractArray{<:Colorant})

Convert an image to HSV.
"""
im2hsv(input_image::AbstractArray{<:Colorant}) = map(HSV, input_image)

"""
    im2separate(input_image::AbstractArray{<:Colorant})

Convert an image to separate channels.
"""
im2separate(input_image::AbstractArray{<:Colorant}) = separate_channels(input_image)

"""
    im2norm(input_image::AbstractArray{<:Colorant})

Convert an image to a normalized channel view.
"""
im2norm(input_image::AbstractArray{<:Colorant}) = normedview(input_image)

"""
    im2raw(input_image::AbstractArray{<:Colorant})

Convert an image to a raw channel view.
"""
im2raw(input_image::AbstractArray{<:Colorant}) = rawview(input_image)

"""
    im2stack(input_image::AbstractArray{<:Colorant})

Convert an image to a stacked view of its channels.
"""
im2stack(input_image::AbstractArray{<:Colorant}) = channelview(input_image)

"""
    seq2stack(input_sequence::AbstractArray{<:AbstractArray{<:Colorant}}...)

Convert a sequence of images to a stacked view.
"""
seq2stack(input_sequence::AbstractArray{<:AbstractArray{<:Colorant}}...) = StackedView(input_sequence...)


