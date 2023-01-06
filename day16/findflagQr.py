from pyzbar.pyzbar import decode
from PIL import Image

Image.MAX_IMAGE_PIXELS = None

im = Image.open(r"haystackNoFrame.png")
imWidth, imHeight = im.size

minimalScanSize = (50,50)

numOfQrSizes = 6
smallestQrSize = 25

uniqueQrStrings = []

numOfScans = 0
numOfScanSuccesses = 0

for scaleStep in range(numOfQrSizes):

    qrSize = smallestQrSize * 2**scaleStep
    steps = int(imWidth/qrSize)

    print("Searching for QR size: " + str(qrSize))

    numOfScans += steps**2
    for vStep in range(steps):
        for hStep in range(steps):
            print("Step: "+str(vStep*steps + hStep)+'/'+str(steps**2), end='\r')

            # Calculate cropping coordinates
            left = hStep * qrSize
            right = left + qrSize
            top = vStep * qrSize
            bottom = top + qrSize

            # Crop out the image part and try to QR-scan it
            tmpIm = im.crop((left,top,right,bottom))
            if qrSize < 50:
                tmpIm = tmpIm.resize(minimalScanSize, Image.Resampling(0))
            qrContent = decode(tmpIm)

            # Check whether the image part could be QR-scanned
            if len(qrContent) > 0:
                numOfScanSuccesses += 1
                qrString = qrContent[0].data.decode("utf-8")
    
                # Check whether QR code string is unique and if so store it
                isUnique = True
                for knownQrStr in uniqueQrStrings:
                    if qrString == knownQrStr:
                        isUnique = False
                        break
                if isUnique:
                    uniqueQrStrings.append(qrString)
                    print("Unique QR string found: "+qrString)

                    # Immediately print everything about QR strings starting
                    # with 'HV' and save a the image data do disk including
                    # coordinates
                    if qrString.find("HV") >= 0:
                        l = str(left)
                        t = str(top)
                        r = str(right)
                        b = str(bottom)
                        print('left:   ' + l)
                        print('top:    ' + t)
                        print('right:  ' + r)
                        print('bottom: ' + b)
                        tmpIm.save(qrString+'_'+l+'_'+t+'_'+r+'_'+b+'.png')

print("\n")
print("Total number of QR scans:            "+str(numOfScans))
print("Total number of successful QR scans: "+str(numOfScanSuccesses))
