from tkinter import *
from tkinter import filedialog
from midiutil.MidiFile import MIDIFile
from math import ceil


def split_txt(filename):

    f = open(filename, "r")

    track = []

    for line in f:
        if line and line != "\n":
            note = []
            for word in line.split():
                note.append(word)
            track.append(note)

    return track


def seconds_to_beats(seconds):
    return ceil(2*seconds)


def assemble_midi(txt_track):

    mf = MIDIFile(1)
    track = 0
    time = 0
    channel = 0
    mf.addTrackName(track, time, "Sample Track")
    mf.addTempo(track, time, 120)

    for note in txt_track:
        pitch, volume, duration = note
        pitch = int(pitch)
        volume = int(volume)
        beats = seconds_to_beats(float(duration))
        mf.addNote(track, channel, pitch, time, beats, volume)
        time += beats + 1

    return mf


def browse_input_file():
    global input_file_path
    input_file_path = filedialog.askopenfilename()


def browse_output_file():
    global output_file_path
    output_file_path = filedialog.asksaveasfilename(defaultextension=".mid")


def generate_midi():
    track = split_txt(input_file_path)
    mf = assemble_midi(track)
    with open(output_file_path, 'wb') as out:
        mf.writeFile(out)


root = Tk()
root.title("MIDI Generator - by EISE3")

# Input file selection
input_file_path = ""
input_frame = Frame(root)
input_frame.pack(side=TOP, pady=5)
input_label = Label(input_frame, text="Select input file:")
input_label.pack(side=LEFT)
input_button = Button(input_frame, text="Browse", command=browse_input_file)
input_button.pack(side=LEFT)

# Output file selection
output_file_path = ""
output_frame = Frame(root)
output_frame.pack(side=TOP, pady=5)
output_label = Label(output_frame, text="Select output file:")
output_label.pack(side=LEFT)
output_button = Button(output_frame, text="Browse", command=browse_output_file)
output_button.pack(side=LEFT)

# Generate button
generate_button = Button(root, text="Generate MIDI", command=generate_midi)
generate_button.pack(side=TOP, pady=5)

root.mainloop()
