
import sys

defs = []
arguments = sys.argv

with open(arguments[1], "r") as file:
    if file != None:
        lump = None
        name = None
        game = None
        authors = None
        for rawline in file:
            line = rawline.strip()

            if line == "":
                defs.append({
                    "lump": lump,
                    "name": name,
                    "game": game,
                    "authors": authors
                })
                lump = None
                name = None
                game = None
                authors = None
                continue

            info = line.split(" ")

            if info[0] == "Lump":
                lump = info[1]
                print("Found lump "+info[1])
            if info[0] == "Title":
                name = info[2].replace("_", " ")
            if info[0] == "Alttitle":
                game = info[2].replace("_", " ")
            if info[0] == "Authors":
                authors = info[2].replace("_", " ")


with open("convMUSICDEF.lua", "w") as file:
    file.write("local MUSICDEF = { \n")
    for curDef in defs:
        if not (curDef.get("lump")):
            continue

        name = curDef.get("name") and '"'+curDef.get("name")+'"' or "nil"
        game = curDef.get("game") and '"'+curDef.get("game")+'"' or "nil"
        authors = curDef.get("authors") and '"'+curDef.get("authors")+'"' or "nil"

        file.write(
        "    "+curDef["lump"]+" = {\n" +
        "        name = "+ name + ",\n" +
        "        game = "+ game + ",\n" +
        "        authors = "+ authors + "\n" +
        "    },\n"
        )
    file.write("}")