using Images: ImageMeta, arraydata, properties, copyproperties, shareproperties, spatialproperties, ColorTypes, minfinite, maxfinite, maxabsfinite, meanfinite

"""
    imageProperties(img)

Returns a dictionary containing properties of the input image.

# Arguments
- `img`: The input image (2D or 3D array).

# Returns
A dictionary with properties of the image.
"""
function imProperties(img)
    # Check image dimensions
    dims = size(img)
    nd = ndims(img)
    elt = eltype(img)
    
    # Collect propertiese
    props = Dict(
        "Dimensions" => dims,
        "Number of Dimensions" => nd,
        "Element Type" => elt,
        "Minimum Pixel Value" => minfinite(img),
        "Maximum Pixel Value" => maxfinite(img),
        "Mean Pixel Value" => meanfinite(img)
    )

    return props
end

"""
    showInfo(img)

Displays metadata and properties of the given image.

# Arguments
- `img`: The input image (can be 2D or 3D).

# Behavior
- Prints properties such as dimensions, number of channels, pixel type, and metadata.
"""
function showInfo(img)
    elt = eltype(img)
    
    println("=== Image Information ===")
    println("Dimensions       : ", size(img))
    println("Number of Dimensions: ", ndims(img))

    println("Element Type     : ", elt)
    println("Minimum Value    : ", minfinite(img))
    println("Maximum Value    : ", maxfinite(img))
    println("Mean Value       : ", meanfinite(img))

    # Attempt to extract and display embedded metadata if available
    try
        metadata = FileIO.query(img, FileIO.ImageMetadata())
        if metadata !== nothing
            println("\n=== Embedded Metadata ===")
            for (key, value) in metadata
                println("$key: $value")
            end
        else
            println("\nNo embedded metadata found.")
        end
    catch e
        println("\nMetadata extraction not supported for this image format.")
    end
end

