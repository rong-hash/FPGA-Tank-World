# resize a png image to different size
# image name should be input as a parameter
# output name and size should also be input as parameters (but optional)
# if width and height isn't input then the image will be resized to ratio input by the user as a parameter

import sys
from PIL import Image

# check if the input is valid
if len(sys.argv) < 2:
    # print the usage
    print("Usage: python resize.py <image name> <output name> [<width> <height> | <ratio>]")
    exit(1)

# open the image
try:
    image = Image.open(sys.argv[1])
except:
    print("Invalid image name")
    exit(1)

# get the width and height of the image
width, height = image.size

# get the output name
if len(sys.argv) >= 3:
    output_name = sys.argv[2]
else:
    output_name = sys.argv[1]

# get the width and height of the output image
if len(sys.argv) >= 5:
    try:
        output_width = int(sys.argv[3])
        output_height = int(sys.argv[4])
    except:
        print("Invalid width or height")
        exit(1)
    
    # resize the image
    image = image.resize((output_width, output_height))

    # save the image
    image.save(output_name)

    # suscess message
    print("Image resized to {}x{} and saved as {}".format(output_width, output_height, output_name))
else:
    try:
        ratio = float(sys.argv[3])
    except:
        print("Invalid ratio")
        exit(1)
    
    # resize the image
    image = image.resize((int(width * ratio), int(height * ratio)))

    # save the image
    image.save(output_name)

    # suscess message
    print("Image resized to {}x{} and saved as {}".format(int(width * ratio), \
                            int(height * ratio), output_name))



exit(0)

