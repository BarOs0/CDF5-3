include("helpers.jl")

using CairoMakie
using TestImages, Images, ImageCore

for file in readdir("analize/", join=true)
    if endswith(file, ".png")
        rm(file)
    end
end

images_dir = "images"
analize_dir = "analize"

img = load(joinpath(images_dir, "budynek.png"))
img_gray = Gray.(img)
x = Float64.(img_gray) .* 255

println("Type: ", typeof(x))
println("Size: rows (height), columns (width): ", size(x))
println("Dimensions: ", ndims(x))
println("Pixels: ", length(x))

x = pad_to_pow2_2d(x)

rows, columns = size(x)
X = zeros(Float64, rows, columns)

levels = 5
gamma = 0.3

for level in 1:levels
    X_level = lift(x, level)
    save(joinpath(analize_dir, "dwt_level_$level.png"), Gray.(normalize_img(abs.(X_level), gamma)))
end

get_subbands(lift(x, 1), 1, analize_dir)

