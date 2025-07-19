
# for doing the GUI
from tkinter import *
from tkinter import ttk, filedialog

# for getting the file's name :P
from pathlib import Path

# type definitions, for vs code :P
from typing import TextIO, List

# for reading/writing lua tables
# pls install it with "pip install luadata"
# if you haven't
try:
    import luadata
except ImportError:
    print("pls install luadata :)")

root = Tk()

root.title("Squigglepants' music entries editor")
root.minsize(320, 200)
root.geometry('640x400')

class VerticalScrolledFrame(ttk.Frame): # me when i copy code from https://coderslegacy.com/python/make-scrollable-frame-in-tkinter/
    def __init__(self, parent, *args, **kw):
        ttk.Frame.__init__(self, parent, *args, **kw)
 
        # Create a canvas object and a vertical scrollbar for scrolling it.
        vscrollbar = ttk.Scrollbar(self, orient=VERTICAL)
        vscrollbar.pack(fill=Y, side=RIGHT, expand=FALSE)
        self.canvas = Canvas(self, bd=0, highlightthickness=0, 
                                width = 200, height = 300,
                                yscrollcommand=vscrollbar.set)
        self.canvas.pack(side=LEFT, fill=BOTH, expand=TRUE)
        vscrollbar.config(command = self.canvas.yview)
 
 
        # Create a frame inside the canvas which will be scrolled with it.
        self.interior = ttk.Frame(self.canvas)
        self.interior.bind('<Configure>', self._configure_interior)
        self.interior_id = self.canvas.create_window(0, 0, window=self.interior, anchor=NW)
        self.canvas.bind('<Configure>', self._configure_canvas)
    
    def _configure_interior(self, event):
        # Update the scrollbars to match the size of the inner frame.
        size = (self.interior.winfo_reqwidth(), self.interior.winfo_reqheight())
        self.canvas.config(scrollregion=(0, 0, size[0], size[1]))
        if self.interior.winfo_reqwidth() != self.canvas.winfo_width():
            # Update the canvas's width to fit the inner frame.
            self.canvas.config(width = self.interior.winfo_reqwidth())
         
    def _configure_canvas(self, event):
        if self.interior.winfo_reqwidth() != self.canvas.winfo_width():
            # Update the inner frame's width to fill the canvas.
            self.canvas.itemconfigure(self.interior_id, width=self.canvas.winfo_width())

entries = {
    "music": [],
    "game": []
}
musicdef = {}
gamedef = {}

# gets index in the thing oooo
def getIndex(array: List, index: int):
    if index < -1:
        index = len(array) + index
    return min(index, len(array)-1)

def deleteEntry(type: str, index: int):
    global entries
    
    entries[type][index].destroy()
    del entries[type][index]

defaultValues = {
    "music": ["name", "game", "authors", "img"],
    "game": ["console", "name", "img"]
}

labelConvert = {
    "music": {
        "name": "Music title:",
        "game": "Game name:",
        "authors": "Authors:",
        "img": "Music image:"
    },
    "game": {
        "console": "Game console:",
        "name": "Internal name:",
        "img": "Default image:"
    }
}

def getLuaParameters(file: TextIO, musicVarName="MUSICDEF", gameVarName="GAMEDEF"):
    curfile = None
    filesFound = {
        "music": "",
        "game": ""
    }

    currentTableLevel = 0
    for rawline in file:
        line = rawline.strip()

        foundMusic = line.find(musicVarName + " =")
        foundGame = line.find(gameVarName + " =")
        if foundMusic == -1 and foundGame == -1 \
        and curfile == None:
            continue
        
        foundOpenTable = line.find("{")
        foundCloseTable = line.find("}")
        if foundOpenTable != -1:
            currentTableLevel += 1
        curfile = (foundMusic != -1 and "music") or (foundGame != -1 and "game") or curfile

        filesFound[curfile] += line+"\n"
        
        if foundCloseTable != -1:
            currentTableLevel -= 1
            if currentTableLevel <= 0:
                curfile = None

    finalMusic, finalGame = None, None
    try:
        finalMusic = luadata.unserialize(filesFound["music"])
    except:
        finalMusic = {}
    
    try:
        finalGame = luadata.unserialize(filesFound["game"])
    except:
        finalGame = {}

    return finalMusic, finalGame

def getMUSICDEFParameters(file: TextIO):
    musicdef = {}
    curMusic = None
    for rawline in file:
        line = rawline.strip()

        if line == "":
            continue

        info = line.split(" ")
        info[0] = info[0].lower()

        if info[0] != "lump" \
        and curMusic == None:
            continue

        curMusic = info[0] == "lump" and info[1] or curMusic
        if not musicdef.get(curMusic):
            musicdef[curMusic] = {}

        if info[0] == "title":
            musicdef[curMusic]["name"] = info[2].replace("_", " ")
        if info[0] == "alttitle":
            musicdef[curMusic]["game"] = info[2].replace("_", " ")
        if info[0] == "authors":
            musicdef[curMusic]["authors"] = info[2].replace("_", " ")
    return musicdef

def doFileStuff(path):
    if not path:
        return

    file = open(path)
    if not file:
        return
    
    global musicdef, gamedef
    if Path(path).suffix == ".lua":
        musicdef, gamedef = getLuaParameters(file)
    else:
        musicdef = getMUSICDEFParameters(file)

    file.close()

waitingText = ttk.Label(root, text="Waiting for your input...")
waitingText.place(relx=0.5, rely=0.25, relwidth=1, relheight=1, anchor=CENTER)
waitingText.pack(expand=1, fill="both")

doFileStuff(
    filedialog.askopenfilename(
        title="Select your file",
        filetypes=[("MUSICDEF", "MUSICDEF*"), ("Lua files", "*.lua"), ("All supported files", ["MUSICDEF*", "*.lua"])]
    )
)

waitingText.destroy()

tabs = ttk.Notebook(root)

tab1 = VerticalScrolledFrame(tabs, padding=10)
tab2 = VerticalScrolledFrame(tabs, padding=10)

tabs.add(tab1, text="Music Definitions")
tabs.add(tab2, text="Game Definitions")
tabs.pack(expand=1, fill="both")

topFrames = {
    "music": ttk.Frame(tab1.interior, padding=10),
    "game": ttk.Frame(tab2.interior, padding=10)
}
for topFrame in topFrames.values():
    topFrame.place(relx=0.5, rely=0.5, anchor=CENTER)
    topFrame.pack(expand=1, fill="both")

theactualimportantinformationthatiwannagetbecauseidontwannabethegalthathasorganizedcode = {
    "music": [],
    "game": []
}

def addEntry(name="", labelName="Music name: ", values={}, location=-1, type="music"):
    frame = ttk.Frame(topFrames[type])
    frame.pack(fill="both")

    nameFrame = ttk.Frame(frame)
    nameFrame.pack(fill="both")

    label = ttk.Label(nameFrame, text=labelName)
    label.pack(fill="x", side="left")

    theStuffTM = {}
    textbox = ttk.Entry(nameFrame)
    textbox.insert(-1, name)
    textbox.pack(expand=1, fill="x", side="left")
    theStuffTM["id"] = textbox
    
    entries[type].insert(location, frame)
    def deleteSelf():
        entry = entries[type].index(frame)
        deleteEntry(type, entry)
        del theactualimportantinformationthatiwannagetbecauseidontwannabethegalthathasorganizedcode[type][entry]
    
    removeButton = ttk.Button(nameFrame, text="X", width=1, command=deleteSelf)
    removeButton.pack(side="right")

    def addAbove():
        addEntry(labelName=labelName, location=max(entries[type].index(frame), 0), type=type)
    
    def addBelow():
        addEntry(labelName=labelName, location=min(entries[type].index(frame)+1, len(entries[type])-1), type=type)

    aboveButton = ttk.Button(nameFrame, text="Add above", command=addAbove)
    belowButton = ttk.Button(nameFrame, text="Add below", command=addBelow)

    aboveButton.pack(expand=1, side="top", fill="both")
    belowButton.pack(expand=1, side="bottom", fill="both")

    textBoxes = {}
    for value in defaultValues[type]:
        entryFrame = ttk.Frame(frame, padding=4)
        entryFrame.pack(fill="both")

        entryLabel = ttk.Label(entryFrame, text=labelConvert[type][value])
        entryLabel.place(relwidth=0.5)
        entryLabel.pack(expand=1, fill="x", side="left")

        entryTextbox = ttk.Entry(entryFrame)
        entryTextbox.pack(expand=1, fill="x", side="left")
        theStuffTM[value] = entryTextbox
        textBoxes[value] = entryTextbox
    
    for defName, definition in values.items():
        textBoxes[defName].insert(-1, definition)

    theactualimportantinformationthatiwannagetbecauseidontwannabethegalthathasorganizedcode[type].insert(location, theStuffTM)
    # update the other frames
    if getIndex(entries[type], location) < len(entries[type])-1 :
        for i in range(getIndex(entries[type], location)+1, len(entries[type])-1):
            entries[type][i].place(relx=0.5, rely=0.5, anchor=CENTER)
            entries[type][i].pack(fill="both")

# Music Definition stuff
if len(musicdef) != 0:
    for entry, definition in musicdef.items():
        addEntry(entry, values=definition)
else:
    addEntry()

# perfectly coded mess :)
if len(gamedef) != 0:
    for entry, definition in gamedef.items():
        addEntry(entry, "Game name: ", definition, type="game")
else:
    addEntry(labelName="Game name: ", type="game")

def saveFile():
    filePath = filedialog.asksaveasfilename(
        title="Save as",
        filetypes=[("Lua files", "*.lua")]
    )

    if not filePath:
        return

    with open(filePath, "w") as file:
        if len(theactualimportantinformationthatiwannagetbecauseidontwannabethegalthathasorganizedcode["music"]) > 0:
            file.write("local MUSICDEF = ")
            musicdef = {}
            for rawentry in theactualimportantinformationthatiwannagetbecauseidontwannabethegalthathasorganizedcode["music"]:
                entry = {}
                for key, val in rawentry.items():
                    newVal = val.get()
                    if newVal != "":
                        entry[key] = newVal

                if entry.get("id") == None or entry["id"] == "":
                    continue

                musicdef[entry["id"]] = {}
                for key, val in entry.items():
                    if key != "id":
                        musicdef[entry["id"]][key] = val
            file.write(luadata.serialize(musicdef, indent="\t"))


        if len(theactualimportantinformationthatiwannagetbecauseidontwannabethegalthathasorganizedcode["game"]) > 0:
            file.write("\n\nlocal GAMEDEF = ")
            gamedef = {}
            for rawentry in theactualimportantinformationthatiwannagetbecauseidontwannabethegalthathasorganizedcode["game"]:
                entry = {}
                for key, val in rawentry.items():
                    newVal = val.get()
                    if newVal != "":
                        entry[key] = newVal
                
                if entry.get("id") == None or entry["id"] == "":
                    continue

                gamedef[entry["id"]] = {}
                for key, val in entry.items():
                    if key != "id":
                        musicdef[entry["id"]][key] = val
            file.write(luadata.serialize(gamedef, indent="\t"))
        
        file.write("\n\nreturn {MUSICDEF, GAMEDEF}")

saveas = ttk.Button(root, text="Save File", command=saveFile)
saveas.pack(expand=1, fill="both", side="left")

ttk.Button(root, text="Close", command=root.destroy).pack(expand=1, fill="both", side="left")

root.mainloop()