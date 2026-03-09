import rawpy
import numpy as np

FILE = "one"
EXT_IN = ".CR2"
EXT_OUT = ".RAW"
PATH_IN = "../images_CR2/"
PATH_OUT = "../images_RAW/" + FILE + EXT_OUT

with rawpy.imread(PATH_IN + (FILE + EXT_IN)) as raw:
    
    rgb = raw.postprocess(
        demosaic_algorithm=rawpy.DemosaicAlgorithm.AHD,  # algorytm demozaikowania
        output_bps=8,        # 8-bit (0-255) 
        no_auto_bright=True, # Bez auto-jasności
        use_camera_wb=True   # White balance z kamery
    )
    
    rgb.tofile(PATH_OUT)
    
    print("\n=== STRUKTURA PLIKU RGB ===")
    print(f"Wymiary: {rgb.shape[1]} × {rgb.shape[0]} pikseli")
    print(f"Plik: {PATH_OUT} ({rgb.nbytes / (1024*1024):.2f} MB)")
    print(f"Format: 3 kanały RGB, {rgb.dtype}")
    print("Kolejność: wiersz po wierszu, piksel po pikselu")
    print(f"Każdy piksel: [R, G, B] (3 bajty)")
    print(f"Pierwszy piksel (RGB): {rgb[0, 0, :]}")
    print(f"Drugi piksel (RGB): {rgb[0, 1, :]}")

    #1. wchodze do folderu ze skryptem pythona
    #2. aktywuje srodowisko: source ../../.venv/bin/activate
    #3. normalnie używam python make_raw.py