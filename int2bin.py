inputfile = "input.txt"

def readinput():
    L = []
    with open(inputfile) as fp:
        for line in fp:
            line = line.rstrip()

            L.append(line)
            
    return L

def splitinput():
    L = [i.split("\n") for i in open(inputfile).read().split("\n\n")]

    return L

output = []
## Parse input
inp = readinput()
#inp = splitinput()

## Solve problem

for i in inp:
    for x in i:
        output.append( ord(x).to_bytes())
    output.append( (0).to_bytes())

f = open("input.bin", "wb")
for o in output:
    f.write(o)
f.close()

