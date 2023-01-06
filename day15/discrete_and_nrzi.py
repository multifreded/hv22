import csv,base64

# Read raw values into list
rawValues = []
with open('raw_values.csv') as csvfile:
    csvreader = csv.reader(csvfile, delimiter=',', quotechar='"')
    for row in csvreader:
        rawValues = row    # There is only one row

# Convert raw values to discrete values
# Low ~= -0.9
# High >= -0.6
discreteValues = []
for rval in rawValues:
    if (float(rval) + 0.7) > 0.0:
        discreteValues.append(1)
    else:
        discreteValues.append(0)

# NZR decoding
bits = []
prevVal=discreteValues[0]
for i in range(1,len(discreteValues)):
    nextVal = discreteValues[i]

    if prevVal == nextVal:
        bits.append(0)
    else:
        bits.append(1)

    prevVal = nextVal

# Convert bitstream to ASCII
byte = 0
place = 7
strVal = ''
for bit in bits:
    byte += ((2**place) * bit)
    place -= 1

    if place < 0:
        strVal += chr(byte)
        byte=0
        place = 7

print(base64.b64decode(bytes(strVal,'UTF-8')))
