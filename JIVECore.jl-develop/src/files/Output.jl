### SAVE FILES

"""
    saveImage(data, filename::String, format::String="png")

Saves data as an image, a gif, or a numbered sequence of images in a folder selected by the user
"""
function saveImage(data, filename::String, format::String="png"; overwrite::Bool=false)
    # Parse supported formats
    supported_formats = split(SUPPORTED_IMAGE_FORMATS, [';', ','])
    
    # Extract the file extension, removing the leading "."
    file_extension = replace(splitext(filename)[end], "." => "") |> lowercase
    
    # Check if the filename already ends with a supported format
    if file_extension in supported_formats
        full_filename = filename
        format_lower = file_extension
    else    
        format_lower = lowercase(format) # Convert the format string to lowercase
        full_filename = filename * "." * format_lower
    end
    
    # Check if the specified format is supported
    if format_lower in supported_formats
        if isfile(full_filename) && !overwrite
            println("File $full_filename already exists. Use overwrite=true to overwrite.")
            return
        end
        try
            FileIO.save(full_filename, data)  # Use FileIO.save explicitly
            println("Image saved as $full_filename")
        catch e
            println("An error occurred: $(e.message)")
        end
    else
        println("Unsupported format: $format")
    end
end

# Pops out a dialog window to save data as an image, a gif, or a numbered sequence of images in a folder selected by the user
function saveImage(data::Matrix)
    path = saveDialog(SUPPORTED_IMAGE_FORMATS)
    isempty(path) ? nothing : saveImage(data, path)
end

function saveImage(data::Dict{String, Any}, 📂::String)
    if !isempty(📂)
        for (name, img) in data
            saveImage(img, joinpath(📂, name))
        end
    end
end

function saveImage(data::Dict{String, Any})
    📂 = saveDialog(true)
    saveImage(data, 📂)
end

"""
    saveImageZip(data, filename::String, format::String="png", foldername::String)

Save an image and compress it into a folder
"""
function saveImageZip(data, filename::String, foldername::String, format::String="png")
    # Save the image first
    saveImage(data, filename, format)
    
    # Create the compressed folder
    compressed_file = foldername * ".zip"
    try
        # Open a ZIP file for writing
        ZipFile.write(compressed_file) do zf
            # Add the image file to the archive
            ZipFile.addfile(zf, filename, filename)
        end
        
        # Remove the original file
        rm(filename)
        println("Image saved and compressed into $compressed_file. Original file removed.")
    catch e
        println("An error occurred: $(e.message)")
    end
end

"""
    path = saveImageTemp(data)

Saves temporary data as a png image with an automatically generated name. 
"""
function saveImageTemp(data)
    path = tempname() * ".png"
    isempty(path) ? nothing : saveImage(data, path)
    return path
end

""" 
    saveImageSequence(images::Array, output_dir::String; format::String = "png", 
                      name::String = "image", start_at::Int = 1, digits::Int = 3,
                      use_labels::Bool = false, labels::Vector{String} = []) 

Save a stack or hyperstack of images as an image sequence.

# Arguments: 
- `images`: An array of image frames or stacks. 
- `output_dir`: Directory to save the output images. 
- `format`: Image format (e.g., png, jpg, bmp). 
- `name`: Base name for the image files. 
- `start_at`: Starting number for the sequence. 
- `digits`: Number of digits in the file numbering. 
- `use_labels`: Whether to use provided labels as filenames. 
- `labels`: Optional labels for each image, required if `use_labels` is `true`.
""" 
function saveImageSequence(images::Array, output_dir::String; format::String = "png", 
                            name::String = "image", start_at::Int = 1, digits::Int = 3, 
                            use_labels::Bool = false, labels::Vector{String} = []) 

    # Create output directory if it doesn't exist 
    isdir(output_dir) || mkpath(output_dir)   

    for (i, img) in enumerate(images) 
        # Generate filename 
        if use_labels 
            if isempty(labels) || length(labels) < i 
                error("Labels must be provided for all images if `use_labels` is true.") 
            end 
            filename = joinpath(output_dir, "$(labels[i]).$format") 
        else 
            file_number = string(start_at + i - 1) |> x -> lpad(x, digits, "0") 
            filename = joinpath(output_dir, "$(name)_$(file_number).$format") 
        end 
        # Save the image 
        saveImage(img, filename) 
    end 
end 

"""
    saveImageStack(stack::Array{T,3}, filename::String) where T<:Real

Saves a single 3D array (grayscale) as a multipage TIFF. Each slice of the 3D array
is saved as a separate page in the TIFF file.

# Arguments:
- `stack`: A 3D array (H × W × D), where D is the number of slices (depth).
- `filename`: The name of the output file (e.g., "grayscale.tiff").
"""
# function saveImageStack(stack::Array{T,3}, filename::String) where T<:Real
#     pages = [Gray.(stack[:, :, z]) for z in axes(stack, 3)]
#     save(filename, pages)
# end

"""
    saveImageStack(stack::NTuple{3, Array{T,3}}, filename::String) where T<:Real

Saves a tuple of three 3D arrays (R, G, B) as a multipage RGB TIFF. Each slice (z-plane)
of the 3D arrays is combined into a color image (RGB) and saved as a separate page
in the TIFF file.

# Arguments:
- `stack`: A tuple of three 3D arrays (R, G, B), each of size (H × W × D), where D is the depth (number of slices).
- `filename`: The name of the output file (e.g., "rgb_stack.tiff").
"""
# function saveImageStack(stack::NTuple{3, Array{T,3}}, filename::String) where T<:Real
#     R, G, B = stack
#     @assert size(R) == size(G) == size(B) "All RGB stacks must have the same dimensions."
#     pages = [RGB.(R[:, :, z], G[:, :, z], B[:, :, z]) for z in axes(R, 3)]
#     save(filename, pages)
# end


"""
    saveVideo()

Saves data as a video in a folder selected by the user
"""
# function saveVideo(data)
#     path = saveDialog(SUPPORTED_VIDEO_FORMATS)
#     isempty(path) ? nothing : VideoIO.save(path, data)
# end
