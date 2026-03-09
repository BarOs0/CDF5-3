include("helpers.jl")

using CairoMakie
using TestImages, Images, ImageCore

for file in readdir("../analize/", join=true)
    if endswith(file, ".png")
        rm(file)
    end
end

images_dir = "../images_RAW"
analize_dir = "../analize"

# Wczytaj surowe dane binarne
raw_data = read(joinpath(images_dir, "one.RAW"))

# === TUTAJ JEST TAK ROBIONE ZE WZGLEDU NA ORIENTACJE MACEIRZY W JULCE ===

# Wymiary obrazu (zgodne z Pythonem)
height = 2348
width = 3522

# Python zapisał (height, width, 3) w formacie row-major: [R,G,B,R,G,B,...]
# Julia używa column-major, więc reshape do (3, width, height)
img_array = reshape(raw_data, (3, width, height))

# Wyciągnij kanały i transpozycja (width × height -> height × width)
r_channel = Float64.(img_array[1, :, :]')
g_channel = Float64.(img_array[2, :, :]')
b_channel = Float64.(img_array[3, :, :]')

# ==========================================================================

println("Type: RGB image with 3 channels")
println("Size per channel: rows (height), columns (width): ", size(r_channel))
println("Dimensions: ", ndims(r_channel))
println("Pixels per channel: ", length(r_channel))

r_channel = pad_to_pow2_2d(r_channel)
g_channel = pad_to_pow2_2d(g_channel)
b_channel = pad_to_pow2_2d(b_channel)

levels = 5
gamma = 0.3

for level in 1:levels
    X_r = lift(r_channel, level)
    X_g = lift(g_channel, level)
    X_b = lift(b_channel, level)
    
    # Rekombinacja kanałów do obrazu RGB
    img_reconstructed = colorview(RGB, 
        normalize_img(abs.(X_r), gamma),
        normalize_img(abs.(X_g), gamma),
        normalize_img(abs.(X_b), gamma))
    
    save(joinpath(analize_dir, "dwt_level_$(level)_rgb.png"), img_reconstructed)
end

