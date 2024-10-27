# Conversion of RGB888 image to RGB565
# lab03 of MYY505 - Computer Architecture
# Department of Computer Engineering, University of Ioannina
# Aris Efthymiou

# This directive declares subroutines. Do not remove it!
.globl rgb888_to_rgb565, showImage

.data

image888:  # A rainbow-like image Red->Green->Blue->Red
    .byte 255, 0,     0
    .byte 255,  85,   0
    .byte 255, 170,   0
    .byte 255, 255,   0
    .byte 170, 255,   0
    .byte  85, 255,   0
    .byte   0, 255,   0
    .byte   0, 255,  85
    .byte   0, 255, 170
    .byte   0, 255, 255
    .byte   0, 170, 255
    .byte   0,  85, 255
    .byte   0,   0, 255
    .byte  85,   0, 255
    .byte 170,   0, 255
    .byte 255,   0, 255
    .byte 255,   0, 170
    .byte 255,   0,  85
    .byte 255,   0,   0
# repeat the above 5 times
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0

image565:
    .zero 512  # leave a 0.5Kibyte free space

.text
# -------- This is just for fun.
# Ripes has a LED matrix in the I/O tab. To enable it:
# - Go to the I/O tab and double click on LED Matrix.
# - Change the Height and Width (at top-right part of I/O window),
#     to the size of the image888 (6, 19 in this example)
# - This will enable the LED matrix
# - Uncomment the following and you should see the image on the LED matrix!
#    la   a0, image888
#    li   a1, LED_MATRIX_0_BASE
#    li   a2, LED_MATRIX_0_WIDTH
#    li   a3, LED_MATRIX_0_HEIGHT
#    jal  ra, showImage
# ----- This is where the fun part ends!

    la   a0, image888
    la   a3, image565
    li   a1, 19 # width
    li   a2,  6 # height
    jal  ra, rgb888_to_rgb565

    addi a7, zero, 10 
    ecall

# ----------------------------------------
# Subroutine showImage
# a0 - image to display on Ripes' LED matrix
# a1 - Base address of LED matrix
# a2 - Width of the image and the LED matrix
# a3 - Height of the image and the LED matrix
# Caution: Assumes the image and LED matrix have the
# same dimensions!
showImage:
    add  t0, zero, zero # row counter
showRowLoop:
    bge  t0, a3, outShowRowLoop
    add  t1, zero, zero # column counter
showColumnLoop:
    bge  t1, a2, outShowColumnLoop
    lbu  t2, 0(a0) # get red
    lbu  t3, 1(a0) # get green
    lbu  t4, 2(a0) # get blue
    slli t2, t2, 16  # place red at the 3rd byte of "led" word
    slli t3, t3, 8   #   green at the 2nd
    or   t4, t4, t3  # combine green, blue
    or   t4, t4, t2  # Add red to the above
    sw   t4, 0(a1)   # let there be light at this pixel
    addi a0, a0, 3   # move on to the next image pixel
    addi a1, a1, 4   # move on to the next LED
    addi t1, t1, 1
    j    showColumnLoop
outShowColumnLoop:
    addi t0, t0, 1
    j    showRowLoop
outShowRowLoop:
    jalr zero, ra, 0

# ----------------------------------------
# Subroutine rgb888_to_rgb565
# a0 - Image to convert
# a1 - Width of the image
# a2 - Height of the image
# a3 - Destination buffer

rgb888_to_rgb565:
    beq a1, zero, convertExit # If either dimension is 0 exit
    beq a2, zero, convertExit
    addi t6, zero, 0x0001     # Detect Endianness
    sh t6, 0(a3)              # Store 0x0001 in the buffer (a1,a2 != 0)
    lbu t6, 0(a3)             # Load the first byte (0 for Big, 1 for Little)
convertRow:
    add t2, a1, zero          # Reset Counter (I'm using t2 and a2)
convertPixel:
    lw t0, 0(a0)              # Get a Pixel as 3 bytes (+1 byte of garbage)
    bne t6, zero, pixel_888_to_565_little # Select Algorithm
pixel_888_to_565_big:
    addi t3, zero, 0b11111000 # Create Mask for Blue
    slli t3, t3, 8            # Move it to the third byte
    and t1, t0, t3            # Get Blue
    srli t1, t1, 11           # Move Blue to the LSBs of the 2nd byte
    
    slli t3, t3, 16           # Create Mask for Red
    and t4, t0, t3            # Get Red
    srli t4, t4, 16           # Move Red to the MSBs of the 1st byte
    or t1, t1, t4             # Set Red in the Result
    
    lui t3, 0b111111000000    # Create Mask for Green
    and t4, t0, t3            # Get Green
    srli t4, t4, 13           # Move Green
    or t1, t1, t4             # Set Green in the Result
    j storePixel
pixel_888_to_565_little:
    addi t3, zero, 0b11111000 # Create Mask for Red
    and t1, t0, t3            # Get Red
    slli t1, t1, 8            # Move Red to the MSBs of the 1st byte
    
    slli t3, t3, 16           # Create Mask for Blue
    and t4, t0, t3            # Get Blue
    srli t4, t4, 19           # Move Blue to the LSBs of the 2nd byte
    or t1, t1, t4             # Set Blue in the Result
    
    addi t3, zero, 0b11111100 # Create Mask for Green
    slli t3, t3, 8            # Move it to the second byte
    and t4, t0, t3            # Get Green
    srli t4, t4, 5            # Move Green
    or t1, t1, t4             # Set Green in the Result
storePixel:
    sh t1, 0(a3)     # Store the Pixel as a half word
    addi a0, a0, 3   # Move Input to the next Pixel
    addi a3, a3, 2   # Move Output to the next Pixel
    addi t2, t2, -1  # Decrement Counter
    bne t2, zero, convertPixel
    addi a2, a2, -1  # Decrement Counter
    bne a2, zero, convertRow
convertExit:
    jalr zero, ra, 0 # Exit
