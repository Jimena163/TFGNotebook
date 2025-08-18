using JIVECore
using Test

@testset "JIVECore.jl" begin
    
    @testset "Files tests" begin
        include("files_tests.jl")
    end

end
