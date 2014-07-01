import sys
from corvus.client import Corvus

def backup(corvus, filename):
    total_sectors = corvus.get_drive_capacity(1)
    with open(filename, "wb") as f:
        for i in range(total_sectors):
            data = corvus.read_sector_512(1, i)
            f.write(''.join([ chr(d) for d in data ]))
            sys.stdout.write("\r%d bytes" % (i * 512))
            sys.stdout.flush()
        sys.stdout.write("\n")

def restore(corvus, filename):
    total_sectors = corvus.get_drive_capacity(1)
    with open(filename, "rb") as f:
        for i in range(total_sectors):
            data = [ ord(d) for d in f.read(512) ]
            if len(data) < 512:
                break
            corvus.write_sector_512(1, i, data)
            sys.stdout.write("\r%d bytes" % (i * 512))
            sys.stdout.flush()
        sys.stdout.write("\n")

def main():
    corvus = Corvus()
    corvus.init_drive()
    backup(corvus, "image.bin")

if __name__ == "__main__":
    main()
