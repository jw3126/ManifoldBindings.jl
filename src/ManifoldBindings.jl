module ManifoldBindings
using Libdl: dlopen
using ArgCheck: @argcheck, @check
using Base.Libc

include("capi.jl")
include("highlevel.jl")
include("makie.jl")


function __init__()
    path = "manifold/build/bindings/c/libmanifoldc.so"
    dlopen(path)
end

end
