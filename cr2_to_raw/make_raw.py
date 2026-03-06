import rawpy
import numpy as np

FILE = "one.CR2"
PATH = "./images_cr2/"
OUTPUT_RGB = "./output_rgb.raw"    # Gotowy RGB dla Julii

with rawpy.imread(PATH + FILE) as raw:
    
    # Gotowy RGB (Python robi demozaikowanie)
    rgb = raw.postprocess(
        demosaic_algorithm=rawpy.DemosaicAlgorithm.AHD,  # algorytm demozaikowania
        output_bps=8,        # 8-bit (0-255) lub 16 (0-65535)
        no_auto_bright=True, # Bez auto-jasności
        use_camera_wb=True   # White balance z kamery
    )
    
    # rgb ma już dobry format (height, width, 3)
    # Zapisz bezpośrednio - piksele są przeplatane [R,G,B,R,G,B,...]
    rgb.tofile(OUTPUT_RGB)
    
    print("\n=== RGB (Python zrobił demozaikowanie) ===")
    print(f"Rozmiar: {rgb.shape}")
    print(f"Format: 3 kanały RGB, {rgb.dtype}")
    print(f"Plik: {OUTPUT_RGB} ({rgb.nbytes / (1024*1024):.2f} MB)")
    
    print("\n=== STRUKTURA PLIKU RGB ===")
    print(f"Wymiary: {rgb.shape[1]} × {rgb.shape[0]} pikseli")
    print("Kolejność: wiersz po wierszu, piksel po pikselu")
    print(f"Każdy piksel: [R, G, B] (3 bajty)")
    print(f"Pierwszy piksel (RGB): {rgb[0, 0, :]}")
    print(f"Drugi piksel (RGB): {rgb[0, 1, :]}")