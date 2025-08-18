using Test, Images, FileIO, VideoIO, CSV, DataFrames
using JIVECore

# Import Data module to access its functions
using ..Data

@testset "Input" begin

    # Test `loadImage`
    @testset "loadImage" begin
        img = Files.loadImage()
        @test img != nothing

        img_path = "test_image.png"
        img_from_path = Files.loadImage(img_path)
        @test img_from_path != nothing
    end

    # Test `loadVideo`
    @testset "loadVideo" begin
        video = Files.loadVideo()
        @test video != nothing
    end

    # Test `loadSequence`
    @testset "loadSequence" begin
        # Test with single image loading
        sequence = Files.loadSequence()
        @test length(sequence) == 2  # Mock returns two images
        @test sequence[1] != nothing

        # Test folder-based sequence loading
        folder_path = "test_folder"
        mkdir(folder_path)  # Mock folder creation
        touch(joinpath(folder_path, "image1.png"))
        touch(joinpath(folder_path, "image2.png"))
        loaded_sequence = Files.loadSequence(folder_path; num_images=1)
        @test length(loaded_sequence) == 1
    end

    # Test `loadImage!`
    @testset "loadImage!" begin
        image_data = Dict()
        image_keys = String[]
        key = Files.loadImage!(image_data, image_keys)
        @test haskey(image_data, key)
        @test key in image_keys

        name = "custom_name"
        key_named = Files.loadImage!(name, image_data, image_keys)
        @test haskey(image_data, key_named)
        @test key_named in image_keys
    end

    # Test `loadClipboard`
    @testset "loadClipboard" begin
        # Mock clipboard content
        function read(cmd::Cmd, ::Type{String})
            return "42"
        end

        # Numeric test
        result = Files.loadClipboard()
        @test result == 42.0

        # Tabular test
        function read(cmd::Cmd, ::Type{String})
            return "col1,col2\n1,2\n3,4"
        end
        result = Files.loadClipboard()
        @test isa(result, DataFrame)

        # Plain text test
        function read(cmd::Cmd, ::Type{String})
            return "Hello, clipboard!"
        end
        result = Files.loadClipboard()
        @test result == "Hello, clipboard!"
    end
end


@testset "Output" begin
    @test_throws MethodError Files.saveImage()
end