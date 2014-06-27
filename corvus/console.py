import sys
from corvus.client import Corvus

def main():
    corvus = Corvus()
    corvus.init_drive()
    total_sectors = corvus.get_drive_capacity(1)
    with open("image.bin", "wb") as f:
        for i in range(total_sectors):
            orig_data = corvus.read_sector_512(1, i)
            corvus.write_sector_512(1, i, orig_data)
            data = corvus.read_sector_512(1, i)
            if data != orig_data: raise ValueError(i)
            f.write(''.join([chr(d) for d in data]))
            f.flush()
            sys.stdout.write("\r%d bytes" % (i * 512))
            sys.stdout.flush()

if __name__ == "__main__":
    main()
