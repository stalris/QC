import sys
from PIL import Image, ImageOps

if __name__ == '__main__':
    print('안녕하세요\n');

    # check for the correct number of arguments.
    if(len(sys.argv) < 3):
        print("Usage: python create_pdf.py output.pdf img1_filepath {img_filepath}");
        sys.exit(1)

    # extract the file paths.
    img_paths = sys.argv[2:]

    # accumulator for the images.
    images = []

    # normalize the images into a pdf-friendly format (RGB)
    for img_path in img_paths:
        with Image.open(img_path) as f:
            i = ImageOps.exif_transpose(f)
            images.append(i.convert("RGB"))

    # convert the Image objects to a pdf.
    images[0].save(sys.argv[1], save_all=True, append_images=images[1:])

    # success!
    print("안녕히 가세요")
